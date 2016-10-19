# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
# Reindexes records syncronously
require_relative 'adapter'
class ActiveRecordReindex::SyncAdapter < ActiveRecordReindex::Adapter

  class << self

    # updates index directly in elasticsearch through
    # Elasticsearch::Model instance method
    # if class not inherited from Elasticsearch::Model it skips since it cannot be reindexing
    # TODO: show error\warning about trying to reindex record that is not connection to elastic
    def call(record)
      return unless _check_elasticsearch_connection(record.class)
      record.update_index
    end

  end

end
