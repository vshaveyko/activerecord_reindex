# coding: utf-8
# frozen_string_literal: true
# author: Vadim Shaveiko <@vshaveyko>
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activerecord_reindex/version'

Gem::Specification.new do |spec|
  spec.name          = 'activerecord_reindex'
  spec.version       = ActiverecordReindex::VERSION
  spec.authors       = ['vs']
  spec.email         = ['vshaveyko@gmail.com']

  spec.summary       = 'Add Elasticsearch reindex option to ActiveRecord associations'
  spec.homepage      = 'https://github.com/Health24/activerecord_reindex'
  spec.license       = 'MIT'

  spec.files = Dir['{lib}/**/*', 'LICENSE', 'README.rdoc']
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '~>5.0'
  spec.add_dependency 'activejob', '~>5.0'
  spec.add_dependency 'elasticsearch-model'
end
