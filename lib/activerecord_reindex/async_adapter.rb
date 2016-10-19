# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
# Asyncronouse reindex adapter
# uses Jobs for reindexing records asyncronously
# Using ActiveJob as dependency bcs activerecord is required for this those
# in most cases it would be used with rails hence with ActiveJob
# later can think about adding support for differnt job adapters
require_relative 'adapter'
class ActiveRecordReindex::AsyncAdapter < ActiveRecordReindex::Adapter

  # Job wrapper. Queues elastic_index queue for each reindex
  class UpdateJob < ActiveJob::Base

    # TODO: make queue name configurable
    queue_as :elastic_index

    def perform(klass, id)
      klass = klass.constantize
      klass.find(id).update_document
    end

  end

  class << self

    def call(record)
      return unless _check_elasticsearch_connection(record.class)
      UpdateJob.perform_later(record.class, record.id)
    end

  end

end
