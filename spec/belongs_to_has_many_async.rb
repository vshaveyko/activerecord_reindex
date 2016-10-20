# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
require 'spec_helper'

class Tag < ActiveRecord::Base

  include Elasticsearch::Model

  has_many :taggings, reindex: :async
  has_many :sync_taggings, reindex: :async

end

class Tagging < ActiveRecord::Base

  include Elasticsearch::Model

  belongs_to :tag, reindex: :async

end

class SyncTagging < ActiveRecord::Base
  include Elasticsearch::Model

  belongs_to :tag, reindex: true
end

describe 'AsyncReindexation' do

  let!(:tagging2) { Tagging.create!(name: 'tagging2') }
  let!(:tagging) { Tagging.create!(tag: tag, name: 'tagging') }
  let!(:tag) { Tag.create!(name: 'tag', taggings: [tagging2]) }

  it 'reindexes belongs_to associated records asyncronous' do
    expect(ActiverecordReindex::AsyncAdapter).to receive(:call).with(tagging2)
    tag.update!(name: 'new tag name')
  end

  it 'reindexes has_many associated records asyncronous' do
    expect(ActiverecordReindex::AsyncAdapter).to receive(:call).with(tag)
    tagging.update!(name: 'tags')
  end

  let!(:sync_tagging2) { SyncTagging.create!(name: 'sync_tagging2') }
  let!(:sync_tagging) { SyncTagging.create!(tag: sync_tag, name: 'sync_tagging') }
  let!(:sync_tag) { Tag.create!(name: 'tag', sync_taggings: [sync_tagging2]) }

  it 'reindexes with job when updated from async reindex side' do
    expect(ActiverecordReindex::AsyncAdapter).to receive(:call).with(sync_tagging)
    tag.update!(name: 'new sync tag')
  end

  it 'reindexes syncr when updated from sync reindex side' do
    expect(ActiverecordReindex::SyncAdapter).to receive(:call).with(sync_tag)
    sync_tagging.update!(name: 'new sync tag')
  end

end
