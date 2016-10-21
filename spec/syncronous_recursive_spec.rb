# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
require 'spec_helper'

class TagD < ActiveRecord::Base

  self.table_name = 'tags'

  has_many :taggings, reindex: true, class_name: 'TagDging', foreign_key: :tag_id
  has_many :sync_taggings, reindex: true, class_name: 'SyncTagDging', foreign_key: :tag_id

end

class TagDging < ActiveRecord::Base

  self.table_name = 'taggings'

  include Elasticsearch::Model

  after_update do |record|
    begin
      record.__elasticsearch__.update_document
    rescue
      nil
    end
  end

  belongs_to :tag, reindex: true, class_name: 'TagD'

end

class SyncTagDging < ActiveRecord::Base

  self.table_name = 'sync_taggings'

  include Elasticsearch::Model

  after_update do |record|
    begin
      record.__elasticsearch__.update_document
    rescue
      nil
    end
  end

  belongs_to :tag, reindex: true, class_name: 'TagD'

end

describe 'Async recursive without non-elastic model in between' do
  let!(:tagging2) { TagDging.create!(name: 'tagging2') }
  let!(:sync_tagging) { SyncTagDging.create!(name: 'sync_tagging2') }
  let!(:tagging) { TagDging.create!(tag: tag, name: 'tagging') }
  let!(:tag) { TagD.create!(name: 'tag', taggings: [tagging2], sync_taggings: [sync_tagging]) }

  it 'reindexes belongs_to associated records asyncronous' do
    expect(ActiverecordReindex::SyncAdapter).to receive(:call).with(tag, tagging)
    expect(ActiverecordReindex::SyncAdapter).to receive(:call).with(sync_tagging, tag)
    expect(ActiverecordReindex::SyncAdapter).to receive(:call).with(taggings2, tag)
    expect(ActiverecordReindex::SyncAdapter).not_to receive(:call).with(tagging, tag)
    begin
      tagging.update!(name: 'new tag name')
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end
  end
end
