# frozen_string_literal: true

# Copyright (C) 2017-2020 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

# Transform given symbol to a constant belonging to a randomized module.
#
# Sample of use:
#
# ```ruby
#  Sampler.new(__FILE__).call(Class.new)
# ```
#
# The name of the given file will be used for the class name.
class Sampler
  autoload(:Pathname, 'pathname')
  autoload(:SecureRandom, 'securerandom')

  # @param [String] filepath
  def initialize(filepath)
    @filepath = filepath
  end

  # @return [Pathname]
  def filepath
    Pathname.new(@filepath)
  end

  # Get a randomized class name (into a namspace module).
  #
  # @return [String]
  def to_s
    self.class.__send__(:modularize, filepath.basename.to_s)
  end

  # Transform to a named constant.
  #
  # @param [Class|Module|Object] const
  def call(const)
    to_s.split('::').tap do |parts|
      current = nil
      parts.each_with_index do |str, i|
        # rubocop:disable Layout/LineLength
        current = (current || Object).const_set(str, parts.size - 1 == i ? const : Module.new)
        # rubocop:enable Layout/LineLength
      end
    end.yield_self { |parts| Object.const_get(parts.join('::')) }
  end

  class << self
    protected

    # Generate a class name form the given string.
    #
    # @return [String]
    def classify(str)
      str.to_s.split(/_|-|\./).collect!(&:capitalize).join
    end

    # Generate a class name into a randomized module form the given string.
    #
    # @return [String]
    def modularize(name, length: 8)
      # rubocop:disable Layout/LineLength
      classify([('a'..'z').to_a.sample, SecureRandom.alphanumeric(length - 1)].join).yield_self do |ns|
        [ns, classify(name)].join('::')
      end
      # rubocop:enable Layout/LineLength
    end
  end
end
