# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
# Reindexes records syncronously
require_relative 'adapter'
class ActiveRecordReindex::SyncAdapter < ActiveRecordReindex::Adapter

  class << self

    # updates index directly in elasticsearch through
    # Elasticsearch::Model instance method
    # if class not inherited from Elasticsearch::Model it raises error
    def call(record)
      return unless _check_elasticsearch_connection(record.class)
      record.update_index
    end

  end

end
