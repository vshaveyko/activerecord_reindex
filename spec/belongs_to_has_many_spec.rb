# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
require 'spec_helper'

class Tag < ActiveRecord::Base

  include Elasticsearch::Model

  class << self

    attr_accessor :reindex_counter

  end

  self.reindex_counter = 0

  has_many :taggings, reindex: true

  def update_document
    self.class.reindex_counter += 1
  end

end

class Tagging < ActiveRecord::Base

  include Elasticsearch::Model

  class << self

    attr_accessor :reindex_counter

  end

  self.reindex_counter = 0

  belongs_to :tag, reindex: true

  def update_document
    self.class.reindex_counter += 1
  end

end

describe Tag do

  let!(:tagging2) { Tagging.create!(name: 'tagging2') }
  let!(:tagging) { Tagging.create!(tag: tag, name: 'tagging') }
  let!(:tag) { Tag.create!(name: 'tag', taggings: [tagging2]) }

  it 'updates document called on association after record update' do
    Tagging.reindex_counter = 0

    tag.update!(name: 'new tag name')
    expect(Tagging.reindex_counter).to eq 1
  end

  it 'update document called on belongs_to assocation' do
    Tag.reindex_counter = 0

    tagging.update!(name: 'new tagging name')
    expect(Tag.reindex_counter).to eq 1
  end

end
