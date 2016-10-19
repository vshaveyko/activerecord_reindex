# :nodoc:
class ActiverecordReindex::Reindexer

  def with_strategy(strategy)
    @strategy = strategy
  end

  def call(record, association_name:, collection?:)
    if collection?
      record.public_send(association_name).each { |associated_record| update_index(associated_record) }
    else
      associated_record = record.public_send(association_name)
      update_index(associated_record)
    end
  end

  private

  # TODO: add bulk reindex if need performance
  def update_index(associated_record)
    check_strategy

    @strategy.call(associated_record)

    clear_strategy
  end

  def check_strategy
    raise ArgumentError, 'No strategy specified.' unless @strategy
  end

  def clear_strategy
    @strategy = nil
  end

end
