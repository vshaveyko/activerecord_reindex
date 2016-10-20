# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
module Elasticsearch
  module Model
    module Indexing
      module InstanceMethods

        alias original_update_document update_document

        # monkey patch update_document method from elasticsearch gem
        # use +super+ and hook on reindex to reindex associations
        # for why request_record needed here and what it is see sync_adapter.rb
        def update_document(*args, request_record: nil)
          if _active_record_model?(self.class)
            _reindex_reflections(self.class, request_record)
          end
          original_update_document(*args)
        end

        private

        def _active_record_model?(klass)
          klass < ActiveRecord::Base
        end

        def _reindex_reflections(klass, request_record)
          klass.sync_reindexable_reflections.each do |reflection|
            target.reindex_sync(reflection, skip_record: request_record)
          end

          klass.async_reindexable_reflections.each do |reflection|
            target.reindex_async(reflection, skip_record: request_record)
          end
        end

      end
    end
  end
end
