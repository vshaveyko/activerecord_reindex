# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>

ActiveRecord::Schema.define(version: 20_161_012_160_507) do
  create_table 'sync_taggings' do |t|
    t.string   'name', limit: 255
    t.integer  'tag_id', limit: 4
    t.datetime 'created_at',                                null: false
    t.datetime 'updated_at',                                null: false
  end
  create_table 'taggings' do |t|
    t.string   'name', limit: 255
    t.integer  'tag_id', limit: 4
    t.datetime 'created_at',                                null: false
    t.datetime 'updated_at',                                null: false
  end

  create_table 'tags' do |t|
    t.string   'name', limit: 255
    t.datetime 'created_at',                 null: false
    t.datetime 'updated_at',                 null: false
  end
end
