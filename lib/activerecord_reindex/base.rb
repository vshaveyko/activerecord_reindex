# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
require_relative 'async_adapter'
require_relative 'sync_adapter'
require_relative 'reindexer'

# ActiveRecord::Base extension to provide methods for
# reindexing callbacks
# this methods requested in callbacks in association.rb
module ActiveRecord
  class Base

    def self.inherited(child)
      super
      class << child

        attr_accessor :reindexer, :async_adapter, :sync_adapter, :sync_reindexable_reflections,
                      :async_reindexable_reflections, :reindex_attr_blacklist, :reindex_attr_whitelist

      end

      # Init default values to prevent undefined method for nilClass error
      child.sync_reindexable_reflections = []
      child.async_reindexable_reflections = []

      child.reindexer = ActiverecordReindex::Reindexer.new
      # TODO: provide config for changing adapters
      # For now can set adapter through writers inside class
      child.async_adapter = ActiverecordReindex::AsyncAdapter
      child.sync_adapter = ActiverecordReindex::SyncAdapter
    end

    def reindex_async(reflection, skip_record: nil)
      _reindex(reflection, strategy: self.class.async_adapter, skip_record: skip_record)
    end

    def reindex_sync(reflection, skip_record: nil)
      _reindex(reflection, strategy: self.class.sync_adapter, skip_record: skip_record)
    end

    private

    def _reindex(reflection, strategy:, skip_record:)
      self.class.reindexer
          .with_strategy(strategy)
          .call(self, reflection: reflection, skip_record: skip_record)
    end

    def changed_index_relevant_attributes?
      return true unless self.class.reindex_attr_blacklist || self.class.reindex_attr_whitelist
      changed = changed_attributes.keys
      wl = self.class.reindex_attr_whitelist&.map(&:to_sym)
      bl = self.class.reindex_attr_blacklist&.map(&:to_sym)

      if wl
        whitelisted = wl & changed
      else
        whitelisted = changed
      end

      if bl
        blacklisted = changed - bl
      else
        blacklisted = []
      end

      !(whitelisted - blacklisted).empty?
    end

  end
end
