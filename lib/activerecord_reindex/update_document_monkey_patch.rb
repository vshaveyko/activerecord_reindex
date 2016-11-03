# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
require 'activerecord_reindex/reflection_reindex'

module Elasticsearch
  module Model
    module Indexing
      module InstanceMethods

        include ActiverecordReindex::ReflectionReindex

        alias original_update_document update_document

        # monkey patch update_document method from elasticsearch gem
        # use +super+ and hook on reindex to reindex associations
        # for why request_record needed here and what it is see sync_adapter.rb
        def update_document(*args, request_record: nil)
          # defined in ActiverecordReindex::ReflectionReindex
          update_document_hook(request_record)

          # If request_record passed - always use index_document to prevent
          # update_document call on non-indexed record
          if request_record
            index_document(*args)
          else
            original_update_document(*args)
          end
        end

      end
    end
  end
end
