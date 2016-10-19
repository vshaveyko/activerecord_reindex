# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
# Abstract adapter class
# New adapters should implement :call method that will perform reindexing of the given record
# Example:
#   def call(record)
#     reindex_it(record)
#   end
class ActiverecordReindex::Adapter

  def self._check_elasticsearch_connection(klass)
    klass < Elasticsearch::Model
  end

end
