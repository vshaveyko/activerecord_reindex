# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
require 'activerecord_reindex/version'

require 'active_record'
require 'active_job'
require 'elasticsearch/model'

require 'activerecord_reindex/association'
require 'activerecord_reindex/association_reflection'

require 'activerecord_reindex/update_document_monkey_patch'

module ActiverecordReindex
end
