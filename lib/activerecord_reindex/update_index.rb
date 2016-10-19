# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
module Elasticsearch::Model

  alias original_update_index update_index

  # monkey patch update_document method from elasticsearch gem
  # use +super+ and hook on reindex to reindex associations
  def update_document(*args)
    original_update_index(*args)
    return unless _active_record_model?(self.class)
    _reindex_reflections(self.class)
  end

  private

  def _active_record_model?(klass)
    klass < ActiveRecord::Base
  end

  def _reindex_reflections(klass)
    klass.sync_reindexable_reflections.each do |reflection|
      _reindex_sync(reflection)
    end

    klass.async_reindexable_reflections.each do |reflection|
      _reindex_async(reflection)
    end
  end

end
