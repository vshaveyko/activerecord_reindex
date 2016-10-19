# encoding: utf-8
# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
# Add helper methods to Activerecord Reflection
# for quick access to reindex options
class ActiveRecord::Reflection::AssociationReflection

  def reindex_sync?
    @options.fetch(:reindex, false) == true
  end

  def reindex_async?
    @options.fetch(:reindex, false) == :async
  end

end

class ActiveRecord::Reflection::ThroughReflection

  def reindex_sync?
    @delegate_reflection.options.fetch(:reindex, false) == true
  end

  def reindex_async?
    @delegate_reflection.options.fetch(:reindex, false) == :async
  end

end
