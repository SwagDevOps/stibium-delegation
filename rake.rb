# frozen_string_literal: true

require_relative 'lib/stibium-delegation'
require_relative 'dev/stibium'

require 'rake'
require 'kamaze/project'
autoload(:YAML, 'yaml')
autoload(:Pathname, 'pathname')

Kamaze::Project.instance do |c|
  c.subject = Stibium::Delegation
  c.name = 'stibium-delegation'
  # @formatter:off
  # noinspection RubyLiteralArrayInspection
  c.tasks = [
    'cs', 'cs:pre-commit',
    'doc', 'doc:watch',
    'gem', 'gem:install',
    'misc:gitignore',
    'shell',
    'sources:license',
    'test',
    'version:edit',
  ].shuffle
  # @formatter:on
end.load!

task default: [:gem]

Stibium::Delegation.class_eval do
  include(Stibium::Bundled).tap do
    self.bundled_path = __dir__

    require 'bundler/setup' if bundled?
    require 'kamaze/project/core_ext/pp' if development?
  end
end

# @type [Kamaze::Project] project
if project.path('spec').directory?
  task :spec do |_task, args|
    Rake::Task[:test].invoke(*args.to_a)
  end
end

if Gem::Specification.find_all_by_name('simplecov').any?
  if YAML.safe_load(ENV['coverage'].to_s) == true
    autoload(:SimpleCov, 'simplecov')

    SimpleCov.start do
      add_filter 'rake/'
      add_filter 'spec/'
    end
  end
end
