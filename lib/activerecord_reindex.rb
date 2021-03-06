# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
require 'activerecord_reindex/version'

module ActiverecordReindex

  class Config

    attr_accessor :index_queue, :index_class, :mass_index_class, :async_reindex_only_in_production

    def initialize
      @index_queue = :elastic_index
      @async_reindex_only_in_production = false
    end

    def async_reindex_only_in_production?
      @async_reindex_only_in_production
    end

    def index_class
      @index_class || ActiverecordReindex::AsyncAdapter::UpdateJob
    end

    def mass_index_class
      @mass_index_class || ActiverecordReindex::AsyncAdapter::MassUpdateJob
    end

  end

  class << self

    def configure
      yield config
    end

    def config
      @_configuration ||= Config.new
    end

    def reset_configuration
      @_configuration = nil
    end

  end

end

# monkey patch active record associations
require 'active_record'
require 'active_job'

require 'activerecord_reindex/base'
require 'activerecord_reindex/association'
require 'activerecord_reindex/association_reflection'

# monkey patch elasticsearch/model
require 'elasticsearch/model'
require 'activerecord_reindex/update_document_monkey_patch'
