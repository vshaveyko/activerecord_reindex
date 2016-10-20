# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>

require_relative 'adapter'
module ActiverecordReindex
  # Asyncronouse reindex adapter
  # uses Jobs for reindexing records asyncronously
  # Using ActiveJob as dependency bcs activerecord is required for this so
  # in most cases it would be used with rails hence with ActiveJob
  # later can think about adding support for differnt job adapters
  class AsyncAdapter < Adapter

    # Job wrapper. Queues elastic_index queue for each reindex
    class UpdateJob < ::ActiveJob::Base

      # TODO: make queue name configurable
      queue_as :elastic_index

      def perform(klass, id, request_record_klass, request_record_id)
        klass = klass.constantize
        request_record = request_record_klass.constantize.find(request_record_id)
        klass.find(id).__elasticsearch__.update_document(request_record: request_record)
      end

    end

    class << self

      # ***nasty-stuff***
      #   hooking into update_document has sudden side-effect
      #   if associations defined two-way they will trigger reindex recursively and result in StackLevelTooDeep
      #   hence to prevent this we're passing request_record to adapter
      #   request record is record that initted reindex for current record as association
      #   we will skip it in associations reindex to prevent recursive reindex and StackLevelTooDeep error
      def call(record, request_record)
        return unless _check_elasticsearch_connection(record.class)
        UpdateJob.perform_later(record.class.to_s, record.id, request_record.class.to_s, request_record.id)
      end

    end

  end
end
