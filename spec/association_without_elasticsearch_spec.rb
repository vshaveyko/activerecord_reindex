# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
require 'spec_helper'

class TagA < ActiveRecord::Base

  self.table_name = 'tags'

  has_many :taggings, reindex: :async, class_name: 'TagAging', foreign_key: :tag_id
  has_many :sync_taggings, reindex: :async, class_name: 'SyncTagAging', foreign_key: :tag_id

end

class TagAging < ActiveRecord::Base

  self.table_name = 'taggings'

  include Elasticsearch::Model

  after_update do |record|
    begin
                            record.__elasticsearch__.update_document
                          rescue
                            nil
                          end
  end

  belongs_to :tag, reindex: :async, class_name: 'TagA'

end

class SyncTagAging < ActiveRecord::Base

  self.table_name = 'sync_taggings'

  include Elasticsearch::Model

  after_update do |record|
    begin
                            record.__elasticsearch__.update_document
                          rescue
                            nil
                          end
  end

  belongs_to :tag, reindex: true, class_name: 'TagA'

end

describe 'AsyncReindexation' do
  let!(:tagging2) { TagAging.create!(name: 'tagging2') }
  let!(:sync_tagging) { SyncTagAging.create!(name: 'sync_tagging2') }
  let!(:tagging) { TagAging.create!(tag: tag, name: 'tagging') }
  let!(:tag) { TagA.create!(name: 'tag', taggings: [tagging2], sync_taggings: [sync_tagging]) }

  it 'reindexes belongs_to associated records asyncronous' do
    expect(ActiverecordReindex::AsyncAdapter).to receive(:call).with(tagging2, tag)
    expect(ActiverecordReindex::AsyncAdapter).to receive(:call).with(sync_tagging, tag)
    expect(ActiverecordReindex::AsyncAdapter).not_to receive(:call).with(tag, any_args)
    expect(ActiverecordReindex::SyncAdapter).not_to receive(:call).with(tag, sync_tagging)
    begin
      tag.update!(name: 'new tag name')
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end
  end

  it 'reindexes has_many associated records asyncronous' do
    expect(ActiverecordReindex::AsyncAdapter).to receive(:call).with(tag, tagging)
    expect(ActiverecordReindex::AsyncAdapter::UpdateJob).not_to receive(:perform).with(tag.class, tag.id, tagging.class, tagging.id)
    expect(ActiverecordReindex::AsyncAdapter).not_to receive(:call).with(tagging, any_args)
    # TODO: add test for nested reindex without modifying application code
    # think about changing ActiveJob behaviour to syncronous
    # expect(ActiverecordReindex::AsyncAdapter).to receive(:call).with(sync_tagging, tag)
    begin
      tagging.update!(name: 'tags')
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end
  end
end
