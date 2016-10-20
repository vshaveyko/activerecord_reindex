# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
require 'spec_helper'

class TagB < ActiveRecord::Base

  self.table_name = 'tags'

  include Elasticsearch::Model

  after_update { |record| record.__elasticsearch__.update_document rescue nil }

  has_many :taggings, reindex: :async, class_name: 'TagBging', foreign_key: :tag_id
  has_many :sync_taggings, reindex: :async, class_name: 'SyncTagBging', foreign_key: :tag_id

end

class TagBging < ActiveRecord::Base

  self.table_name = 'taggings'

  include Elasticsearch::Model

  after_update { |record| record.__elasticsearch__.update_document rescue nil }

  belongs_to :tag, reindex: :async, class_name: 'TagB'

end

class SyncTagBging < ActiveRecord::Base

  self.table_name = 'sync_taggings'

  include Elasticsearch::Model

  after_update { |record| record.__elasticsearch__.update_document rescue nil }

  belongs_to :tag, reindex: true, class_name: 'TagB'

end

describe 'AsyncReindexation' do

  let!(:tagging2) { TagBging.create!(name: 'tagging2') }
  let!(:tagging) { TagBging.create!(tag: tag, name: 'tagging') }
  let!(:tag) { TagB.create!(name: 'tag', taggings: [tagging2], sync_taggings: [sync_tagging]) }

  it 'reindexes belongs_to associated records asyncronous' do
    expect(ActiverecordReindex::AsyncAdapter).to receive(:call).with(tagging2, tag)
    expect(ActiverecordReindex::AsyncAdapter).to receive(:call).with(sync_tagging, tag)
    # expect(ActiverecordReindex::SyncAdapter).to receive(:call).with(sync_tag, sync_tagging)
    expect(ActiverecordReindex::AsyncAdapter).not_to receive(:call).with(tag, any_args)

    begin
      tag.update!(name: 'new tag name')
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end
  end

  it 'reindexes has_many associated records asyncronous' do
    expect(ActiverecordReindex::AsyncAdapter).to receive(:call).with(tag, tagging)
    expect(ActiverecordReindex::AsyncAdapter).not_to receive(:call).with(tagging, tag)
    # expect(ActiverecordReindex::AsyncAdapter).to receive(:call).with(sync_tagging, tag)
    # expect(ActiverecordReindex::SyncAdapter).to receive(:call).with(sync_tag, sync_tagging)
    begin
    tagging.update!(name: 'tags')
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end
  end

  let!(:sync_tagging2) { SyncTagBging.create!(name: 'sync_tagging2') }
  let!(:sync_tagging) { SyncTagBging.create!(tag: sync_tag, name: 'sync_tagging') }
  let!(:sync_tag) { TagB.create!(name: 'tag', sync_taggings: [sync_tagging2]) }

  it 'reindexes with job when updated from async reindex side' do
    expect(ActiverecordReindex::AsyncAdapter).to receive(:call).with(sync_tagging2, sync_tag)
    expect(ActiverecordReindex::SyncAdapter).not_to receive(:call).with(sync_tag, sync_tagging2)
    begin
    sync_tag.update!(name: 'new sync tag')
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end
  end

  it 'reindexes syncr when updated from sync reindex side' do
    # expect(ActiverecordReindex::SyncAdapter).to receive(:call).with(sync_tag, sync_tagging)
    expect(ActiverecordReindex::AsyncAdapter).not_to receive(:call).with(sync_tagging, sync_tag)
    begin
    sync_tagging.update!(name: 'new sync tag')
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end
  end

end
