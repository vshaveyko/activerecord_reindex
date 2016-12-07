# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
# Reindexes records syncronously
require_relative 'adapter'
module ActiverecordReindex
  class SyncAdapter < Adapter

    class << self

      private

      def _single_reindex(request_record, record)
        _update_index_on_record(record, request_record)
      end

      def _mass_reindex(request_record, _class_name, records)
        records.each do |record|
          _update_index_on_record(record, request_record)
        end
      end

      def _update_index_on_record(record, request_record)
        record.__elasticsearch__.update_document(request_record: request_record)
      rescue Elasticsearch::Transport::Transport::Errors::NotFound
        record.__elasticsearch__.index_document
      end

    end

  end

end
