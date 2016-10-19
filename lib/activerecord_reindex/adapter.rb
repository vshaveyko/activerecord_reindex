# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
# Abstract adapter class
# New adapters should implement :call method that will perform reindexing of the given record
# Example:
#   def call(record)
#     reindex_it(record)
#   end
class ActiverecordReindex::Adapter

  # check if record of this class can be reindexed
  # check if klass inherits from elasticsearch-model base class
  # and have method required for reindexing
  def self._check_elasticsearch_connection(klass)
    klass < Elasticsearch::Model
  end

end
