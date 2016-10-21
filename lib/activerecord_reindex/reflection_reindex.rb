# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
# helpers for reindexing all required reflections on record's class
module ActiverecordReindex
  module ReflectionReindex

    def update_document_hook(request_record)
      return unless _active_record_model?(self.class)
      _reindex_reflections(self.class, request_record)
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
