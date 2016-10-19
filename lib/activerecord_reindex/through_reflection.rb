# encoding: utf-8
class ActiveRecord::Reflection::ThroughReflection

  def reindex_sync?
    @delegate_reflection.options.fetch(:reindex, false) == true
  end

  def reindex_async?
    @delegate_reflection.options.fetch(:reindex, false) == :async
  end

end
