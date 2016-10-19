# encoding: utf-8
# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>

require_relative 'async_adapter'
require_relative 'sync_adapter'
require_relative 'reindexer'
# Adds reindex option to associations
# values accepted are true, :async. Default false.
# If true it will add syncronous elasticsearch reindex callbacks on:
# 1. record updated
# 2. record destroyed
# 3. record index updated
# if :async it will add async callbacks in same cases
class ActiveRecord::Associations::Builder::Association

  class << self
    attr_accessor :reindexer, :async_adapter, :sync_adapter
  end

  self.reindexer = ActiveRecordReindex::Reindexer.new
  # TODO: provide config for changing adapters
  # For now can set adapter through writers inside class
  self.async_adapter = ActiveRecordReindex::AsyncAdapter
  self.sync_adapter = ActiveRecordReindex::SyncAdapter

  class << self

     alias original_valid_options valid_options

     # This method monkey patches ActiveRecord valid_options to add one more valid option :reindex
     # Examples:
     #   belongs_to :tag, reindex: true
     #   belongs_to :tagging, reindex: :async
     #   has_many :tags, reindex: async
     #   has_many :tags, through: :taggings, reindex: true
     def valid_options(*args)
       original_valid_options(*args) + [:reindex]
     end

     alias original_define_callbacks define_callbacks

     # This method monkeypatches ActiveRecord define_callbacks to
     # add reindex callbacks if corresponding option specified
     # if reindex; true - add syncronous callback to reindex associated records
     # if reindex: :async - add asyncronous callback to reindex associated records
     def define_callbacks(model, reflection)
       original_define_callbacks(model, reflection)
       if reflection.reindex_sync?
         add_reindex_callback(model, reflection, async: false)
       elsif reflection.reindex_async?
         add_reindex_callback(model, reflection, async: true)
       end
     end

    private

     # manages adding of callbacks considering async option
     def add_reindex_callback(model, reflection, async:)
       add_destroy_reindex_callback(model, reflection, async: async)

       add_update_reindex_callback(model, reflection, async: async)
     end

     # add callback to reindex associated records on destroy
     # if association has dependent: :destroy or dependent: :delete_all
     # we skip this callback since destroyed records should reindex themselves
     def add_destroy_reindex_callback(model, reflection, async:)
       return if reflection.options[:dependent].in? [:destroy, :delete_all]

       model.after_commit on: :destroy, &callback(async, reflection)
     end

     # add callback to reindex associations on update
     def add_update_reindex_callback(model, reflection, async:)
       model.after_commit on: :update, &callback(async, reflection)
     end

     def callback(async, reflection)
       async ? -> { _reindex_async(reflection) } : -> { _reindex_sync(reflection) }
     end

  end

  private

  def _reindex_async(reflection)
    self.class.reindexer
      .with_strategy(self.class.async_adapter)
      .call(self, association_name: reflection.name, collection?: reflection.collection?)
  end

  def _reindex_sync(reflection)
    self.class.reindexer
      .with_strategy(self.class.sync_adapter)
      .call(self, association_name: reflection.name, collection?: reflection.collection?)
  end

end
