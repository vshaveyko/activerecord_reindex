# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
require_relative 'async_adapter'
require_relative 'sync_adapter'
require_relative 'reindexer'

# ActiveRecord::Base extension to provide methods for
# reindexing callbacks
# this methods requested in callbacks in association.rb
class ActiveRecord::Base

  class << self

    attr_accessor :reindexer, :async_adapter, :sync_adapter, :sync_reindexable_reflections, :async_reindexable_reflections

  end

  self.reindexer = ActiveRecordReindex::Reindexer.new
  # TODO: provide config for changing adapters
  # For now can set adapter through writers inside class
  self.async_adapter = ActiveRecordReindex::AsyncAdapter
  self.sync_adapter = ActiveRecordReindex::SyncAdapter

  private

  # reindex reflection associations record skipping skip_record if applicable
  # for why we need to skip some records see sync_adapter.rb doc
  def _reindex_async(reflection, skip_record: nil)
    self.class.reindexer
        .with_strategy(self.class.async_adapter)
        .call(self, association_name: reflection.name, collection?: reflection.collection?, skip_record: skip_record)
  end

  def _reindex_sync(reflection, skip_record: nil)
    self.class.reindexer
        .with_strategy(self.class.sync_adapter)
        .call(self, association_name: reflection.name, collection?: reflection.collection?, skip_record: skip_record)
  end

end
