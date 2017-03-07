class TagC < ActiveRecord::Base

  self.table_name = 'tags'

  self.reindex_attr_whitelist = ['name']

  include Elasticsearch::Model

  # rescue nil required to ignore errors from real elastic
  # we're not interested in index status in this test
  # we're only looking for correct hooks execution
  after_update { |record| record.__elasticsearch__.update_document rescue nil }

  has_many :taggings, reindex: true, class_name: 'TagCging', foreign_key: :tag_id

end

class TagCging < ActiveRecord::Base

  self.table_name = 'taggings'

  include Elasticsearch::Model

  after_update { |record| record.__elasticsearch__.update_document rescue nil }

  belongs_to :tag, reindex: true, class_name: 'TagC'

end

describe TagC do

  let!(:tagging2) { TagCging.create!(name: 'tagging2') }
  let!(:tagging) { TagCging.create!(tag: tag, name: 'tagging') }
  let!(:tag) { TagC.create!(name: 'tag', taggings: [tagging2]) }

  it 'updates document called if relevant attr updated' do
    expect(ActiverecordReindex::SyncAdapter).to receive(:call).with(tagging2, tag)
    expect(ActiverecordReindex::SyncAdapter).not_to receive(:call).with(tag, any_args)

    tag.update!(name: 'new tag name')
  end

  it 'updates document is not called if unrelevant attr updated' do
    expect(ActiverecordReindex::SyncAdapter).not_to receive(:call).with(tagging2, tag)

    tag.update!(updated_at: Time.current)
  end

end
