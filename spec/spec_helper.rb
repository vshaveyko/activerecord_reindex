# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'pry'

require 'rspec/rails'
require 'database_cleaner'
require 'jazz_hands'

require 'activerecord_reindex'

RSpec.configure do |config|
  config.order = 'random'
  config.formatter = :documentation

  config.before :suite do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.orm = 'active_record'
  end

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end
end
