# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'pry'
require 'active_record'
require 'active_job'
require 'elasticsearch/model'
require 'activerecord_reindex'
require 'nulldb_rspec'

include NullDB::RSpec::NullifiedDatabase

RAILS_ROOT = File.expand_path(File.dirname(__FILE__) + '/..')

NullDB.configure do |ndb|
  def ndb.project_root
    RAILS_ROOT
  end
end

ActiveRecord::Base.establish_connection adapter: :nulldb, schema: 'spec/schema.rb'

ActiveRecord::Base.configurations['test'] = { 'adapter' => 'nulldb' }

# Here's where you force NullDB to do your bidding
RSpec.configure do |config|
  config.before(:each) do
    schema_path = File.join(RAILS_ROOT, 'spec/schema.rb')
    NullDB.nullify(schema: schema_path)
  end

  config.after(:each) do
    NullDB.restore
  end
end
