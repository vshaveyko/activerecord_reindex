# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
# Asyncronouse reindex adapter
# uses Jobs for reindexing records asyncronously
# any additional adapter provided must implement :call method
class ActiveRecordReindex::AsyncAdapter

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
      _check_elasticsearch_connection(record.class)
      UpdateJob.perform_later(record.class, record.id)
    end

    def _check_elasticsearch_connection(klass)
      return if klass.ancestors.map(&:to_s).include?('Elasticsearch::Model')
      raise StandardError, "Class #{record.class} must include Elasticsearch::Model to provide reindexing methods."
    end

  end

end
