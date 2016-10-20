# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
module ActiverecordReindex
  class Reindexer

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
    def call(record, reflection:, skip_record:)
      if reflection.collection?
        _reindex_collection(reflection, record, skip_record)
      else
        associated_record = record.public_send(reflection.name)
        return if associated_record == skip_record
        _update_index(associated_record, record)
      end
    end

    private

    # TODO: add bulk reindex if need performance
    # raise if strategy was not specified or doesn't respond to call which is required for strategy
    # pass record to strategy and execute reindex
    # clear strategy to not mess up future reindexing
    def _update_index(associated_record, record)
      _check_strategy

      @strategy.call(associated_record, record)

      _clear_strategy
    end

    def _check_strategy
      raise ArgumentError, 'No strategy specified.' unless @strategy
      raise ArgumentError, "Strategy specified incorrect. Check if #{@strategy} responds to :call." unless @strategy.respond_to? :call
    end

    def _clear_strategy
      @strategy = nil
    end

    def _reindex_collection(reflection, record, skip_record)
      collection = record.public_send(reflection.name)

      collection -= [skip_record] if reflection.klass == skip_record.class

      collection.each do |associated_record|
        _update_index(associated_record, record)
      end
    end

  end
end
