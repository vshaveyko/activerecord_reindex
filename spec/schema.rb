# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>

ActiveRecord::Schema.define(version: 20_161_015_122_737) do
  create_table 'tags', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
    t.string   'name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'taggings', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
    t.string 'name'
    t.integer  'tag_id'
    t.datetime 'created_at',                        null: false
    t.datetime 'updated_at',                        null: false
    t.index ['tag_id'], name: 'index_access_rights_on_receiving_doctor_id', using: :btree
  end

  create_table 'sync_taggings', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
    t.string 'name'
    t.integer  'tag_id'
    t.datetime 'created_at',                        null: false
    t.datetime 'updated_at',                        null: false
    t.index ['tag_id'], name: 'index_access_rights_on_receiving_doctor_id', using: :btree
  end
end
