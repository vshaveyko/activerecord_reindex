# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
class ActiverecordReindex::Reindexer

  # chain strategy before actual executing
  # strategy can be either sync or async
  # corresponding to type of reindexing
  # additional strategies can be defined and specified by user
  def with_strategy(strategy)
    @strategy = strategy
    self
  end

  # reindex records associated with given record on given association
  # if association is collection(has_many, has_many_through, has_and_belongs_to_many)
  #   get all associated recrods and reindex them
  # else
  #   reindex given record associted one
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
  # raise if strategy was not specified or doesn't respond to call which is required for strategy
  # pass record to strategy and execute reindex
  # clear strategy to not mess up future reindexing
  def update_index(associated_record)
    check_strategy

    @strategy.call(associated_record)

    clear_strategy
  end

  def check_strategy
    raise ArgumentError, 'No strategy specified.' unless @strategy
    raise ArgumentError, "Strategy specified incorrect. Check if #{@strategy} responds to :call." unless @strategy.respond_to? :call
  end

  def clear_strategy
    @strategy = nil
  end

end
