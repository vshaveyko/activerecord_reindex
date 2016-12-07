# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
require_relative 'adapter'
module ActiverecordReindex
  #
  # Asyncronouse reindex adapter
  # uses Jobs for reindexing records asyncronously
  # Using ActiveJob as dependency bcs activerecord is required for this so
  # in most cases it would be used with rails hence with ActiveJob
  # later can think about adding support for differnt job adapters
  #
  class AsyncAdapter < Adapter

    #
    # Job wrapper. Queues elastic_index queue for each reindex
    #
    class UpdateJob < ::ActiveJob::Base

      queue_as RailsApiDoc.config.index_queue

      def perform(klass, id, request_record_klass, request_record_id)
        klass = klass.constantize

        request_record = request_record_klass.constantize.find(request_record_id)

        klass.find(id).__elasticsearch__.update_document(request_record: request_record)
      end

    end

    class MassUpdateJob < ::ActiveJob::Base

      queue_as RailsApiDoc.config.index_queue

      def perform(klass, ids, request_record_klass, request_record_id)
        klass = klass.constantize

        request_record = request_record_klass.constantize.find(request_record_id)

        klass.find(ids).each do |record|
          record.__elasticsearch__.update_document(request_record: request_record)
        end
      end

    end

    class << self

      private

      #
      # UpdateJob is default for this
      # uses configured job class otherwise
      #
      def _single_reindex(request_record, record)
        ActiverecordReindex::Config.index_class
          .perform_later(record.class.name,
                         record.id,
                         request_record.class.name,
                         request_record.id)
      end

      #
      # MassUpdateJob is default for this
      # uses configured job class otherwise
      #
      # used for saving time on creating jobs in realtime
      # create one job that will reindex all records internally
      #
      def _mass_reindex(request_record, class_name, records)
        ActiverecordReindex::Config.mass_index_class
          .perform_later(class_name,
                         records.ids,
                         request_record.class.name,
                         request_record.id)
      end

    end

  end
end
