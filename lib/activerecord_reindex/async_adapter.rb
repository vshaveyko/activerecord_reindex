# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
# Asyncronouse reindex adapter
# uses Jobs for reindexing records asyncronously
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
