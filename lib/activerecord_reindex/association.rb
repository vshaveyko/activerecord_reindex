# encoding: utf-8
# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
# Adds reindex option to associations
# values accepted are true, :async. Default false.
# If true it will add syncronous elasticsearch reindex callbacks on:
# 1. record updated
# 2. record destroyed
# 3. record index updated
# if :async it will add async callbacks in same cases
require_relative 'reindex_hook'

module ActiveRecord
  module Associations
    module Builder
      class Association

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
              model.sync_reindexable_reflections += [reflection]
            elsif reflection.reindex_async?
              add_reindex_callback(model, reflection, async: true)
              model.async_reindexable_reflections += [reflection]
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
            return if [:destroy, :delete_all].include? reflection.options[:dependent]

            model.after_commit on: :destroy, &callback(async, reflection)
          end

          # add callback to reindex associations on update
          # if model inherited from Elasticsearch::Model it means it have own index in elasticsearch
          # and therefore should reindex itself on update those triggering update_document hook
          # to prevent double reindex we're not adding update callback on such models
          def add_update_reindex_callback(model, reflection, async:)
            return if model < Elasticsearch::Model

            # for why it is needed see reindex_hook.rb
            model.include ActiverecordReindex::ReindexHook

            destroy_callback = callback(async, reflection)

            model.after_commit(on: :update) do
              next unless changed_index_relevant_attributes?
              destroy_callback.call
            end
          end

          # callback methods defined in ActiveRecord::Base monkeypatch
          def callback(async, reflection)
            async ? -> { reindex_async(reflection) } : -> { reindex_sync(reflection) }
          end

        end

      end
    end
  end
end
