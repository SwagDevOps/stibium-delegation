# frozen_string_literal: true

# Copyright (C) 2017-2020 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

# Copyright (C) 2019-2020 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

# Bundled behavior.
#
# Allow to detect bundled execution due to ``gems.rb`` and ``gems.locked``
# files presence, and``development`` execution (``gemspec.tpl`` file presence).
module Stibium::Bundled
  autoload(:Pathname, 'pathname')

  class << self
    def included(base)
      base.extend(ClassMethods)

      Pathname.new(caller_locations.first.path).dirname.tap do |caller_path|
        (base.__send__(:bundled_path) || caller_path).tap do |path|
          base.__send__(:bundled_path=, Pathname(path).join('..'))
        end
      end
    end
  end

  # Class methods
  module ClassMethods
    protected

    # @param [String] path
    # @return [Pathname]
    def bundled_path=(path)
      @bundled_path = Pathname.new(path).realpath
    end

    # @return [Pathname]
    def bundled_path
      @bundled_path
    end

    # Denote current class is used in a bundled context.
    #
    # @return [Boolean]
    def bundled?
      # @formatter:off
      [%w[gems.rb gems.locked], %w[Gemfile Gemfile.lock]].map do |m|
        Dir.chdir(bundled_path) do
          m.map { |f| Pathname(f).file? }.uniq
        end
      end.include?([true])
      # @formatter:on
    end

    # Denote current class is used in development context.
    #
    # @return [Boolean]
    def development?
      # @formatter:off
      bundled? and [['gemspec.tpl']].map do |m|
        Dir.chdir(bundled_path) do
          m.map { |f| Pathname(f).file? }
        end
      end.include?([true])
      # @formatter:on
    end
  end
end
