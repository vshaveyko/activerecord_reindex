# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
require 'activerecord_reindex/version'

# monkey patch active record associations
require 'active_record'
require 'active_job'

require 'activerecord_reindex/base'
require 'activerecord_reindex/association'
require 'activerecord_reindex/association_reflection'

# monkey patch elasticsearch/model
require 'elasticsearch/model'
require 'activerecord_reindex/update_document_monkey_patch'

module ActiverecordReindex
end
