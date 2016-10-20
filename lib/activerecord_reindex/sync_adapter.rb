# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
# Reindexes records syncronously
require_relative 'adapter'
class ActiverecordReindex::SyncAdapter < ActiverecordReindex::Adapter

  class << self

    # updates index directly in elasticsearch through
    # Elasticsearch::Model instance method
    # if class not inherited from Elasticsearch::Model it skips since it cannot be reindexing
    # TODO: show error\warning about trying to reindex record that is not connection to elastic
    # ***nasty-stuff***
    #   hooking into update_document has sudden side-effect
    #   if associations defined two-way they will trigger reindex recursively and result in StackLevelTooDeep
    #   hence to prevent this we're passing request_record to adapter
    #   request record is record that initted reindex for current record as association
    #   we will skip it in associations reindex to prevent recursive reindex and StackLevelTooDeep error
    def call(record, request_record)
      return unless _check_elasticsearch_connection(record.class)
      record.__elasticsearch__.update_document(request_record: request_record)
    end

  end

end
