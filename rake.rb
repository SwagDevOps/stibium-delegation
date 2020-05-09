# frozen_string_literal: true

require 'rake'
autoload(:YAML, 'yaml')
autoload(:Pathname, 'pathname')

if Gem::Specification.find_all_by_name('simplecov').any?
  if YAML.safe_load(ENV['coverage'].to_s) == true
    autoload(:SimpleCov, 'simplecov').tap do
      SimpleCov.start do
        ['rake/', 'spec/', 'dev/'].each { |path| add_filter(path) }
      end
    end
  end
end

require_relative('dev/project').tap { Kamaze::Project.instance.load! }

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
