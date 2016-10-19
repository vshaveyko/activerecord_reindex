# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
# Reindexes records syncronously
# any additional adapter provided must implement :call method
class ActiveRecordReindex::SyncAdapter

  class << self

    # updates index directly in elasticsearch through
    # Elasticsearch::Model instance method
    # if class not inherited from Elasticsearch::Model it raises error
    def call(record)
      _check_elasticsearch_connection(record.class)
      record.update_index
    end

    private

    def _check_elasticsearch_connection(klass)
      return if klass.ancestors.map(&:to_s).include?('Elasticsearch::Model')
      raise StandardError, "Class #{record.class} must include Elasticsearch::Model to provide reindexing methods."
    end

  end

end
