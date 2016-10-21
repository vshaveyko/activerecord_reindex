# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
module ActiverecordReindex
  # Since recursive reindexing can go through models that does not
  # exist in elastic and not inherited from Elsaticsearch::Model
  # they will not have __elasticsearch__.update_document method
  # those will stop recursive reindexing chain in its way
  # To prevent this we emulate __elasticsearch__.update_document on them
  # and continue reindex chain as is, without reindexing this records
  module ReindexHook

    def __elasticsearch__
      @__elasticsearch__ ||= ActiverecordReindex::ElasticsearchProxy.new(self.class)
    end

  end

  # Proxy to imitate missing __elasticsearch__ on models without
  # Elasticsearch::Model included
  require 'activerecord_reindex/reflection_reindex'
  class ElasticsearchProxy

    include ActiverecordReindex::ReflectionReindex

    def initialize(klass)
      @klass = klass
    end

    def update_document(*, request_record: nil)
      # defined in ActiverecordReindex::ReflectionReindex
      update_document_hook(request_record)
    end

  end

end
