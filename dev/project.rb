# frozen_string_literal: true

require 'kamaze/project'
require_relative 'stibium'

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
end
