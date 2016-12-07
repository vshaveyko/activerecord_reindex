# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
# Abstract adapter class
# New adapters should implement :_single_reindex and :_mass_reindex methods that will perform reindexing of the given records
#
module ActiverecordReindex
  class Adapter

    #
    # check if record of this class can be reindexed ==
    # check if klass inherits from elasticsearch-model base class
    #
    def self._check_elasticsearch_connection(klass)
      klass < Elasticsearch::Model
    end

    #
    # updates index directly in elasticsearch through
    # Elasticsearch::Model instance method
    # if class not inherited from Elasticsearch::Model it skips since it cannot be reindexed
    #
    # ***nasty-stuff***
    #   hooking into update_document has sudden side-effect
    #   if associations defined two-way they will trigger reindex recursively and result in StackLevelTooDeep
    #   hence to prevent this we're passing request_record to adapter
    #   request record is record that initted reindex for current record as association
    #   we will skip it in associations reindex to prevent recursive reindex and StackLevelTooDeep error
    #
    def self.call(record: nil, records: nil, request_record)
      if record
        return unless _check_elasticsearch_connection(record.class)

        _single_reindex(request_record, record)
      elsif records && record = records.first
        return unless _check_elasticsearch_connection(record.class)

        _mass_reindex(request_record, record.class.name, records)
      end
    end

  end

end
