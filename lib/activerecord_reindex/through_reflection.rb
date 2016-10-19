# encoding: utf-8
# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
class ActiveRecord::Reflection::ThroughReflection

  def reindex_sync?
    @delegate_reflection.options.fetch(:reindex, false) == true
  end

  def reindex_async?
    @delegate_reflection.options.fetch(:reindex, false) == :async
  end

end
