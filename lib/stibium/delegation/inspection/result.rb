# frozen_string_literal: true

# Copyright (C) 2017-2020 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../inspection'

# Describe the inspection result.
class Stibium::Delegation::Inspection::Result
  def initialize
    @state = {}
    @parameterizers = self.class.__send__(:parameterizers_for, self)
  end

  # @param [Symbol] type
  # @param [Symbol|nil] name
  def add(type, name)
    self.tap do
      self.parameterize(type, name).tap do |res|
        # @formatter:off
        state[state.values.length] = [
          [type, name].map { |v| v.nil? ? nil : v.to_sym }, res
        ].map(&:freeze).freeze
        # @formatter:on
      end
    end
  end

  # Denote contains keyrest parameter.
  #
  # @return [Boolean]
  def keyrest?
    !to_a.grep(/^\*{2}[a-z_][a-zA-Z_0-9]*$/).empty?
  end

  # Denote contains rest parameter.
  #
  # @return [Boolean]
  def rest?
    !to_a.grep(/^\*[a-z_][a-zA-Z_0-9]*$/).empty?
  end

  # Get a string compatbible with a method signature.
  #
  # @return [String]
  def to_s
    to_a.join(', ').freeze
  end

  def to_a
    state.values.map { |v| v[1] }.compact.map(&:freeze).freeze
  end

  # Get as parameters (usable for method call).
  #
  # @return [Array<String>]
  def parameters
    to_a.map { |str| str.gsub(/:$/, '') }.map(&:freeze).freeze
  end

  protected

  # @return [Hash{Integer => Array}]
  attr_accessor :state

  # @return [Hash{Symbol => Proc}]
  attr_reader :parameterizers

  class << self
    protected

    # rubocop:disable Metrics/MethodLength, Layout/LineLength

    # @api private
    #
    # @param [Result] result
    #
    # @return [Hash{Symbol => Proc}]
    def parameterizers_for(result)
      parameterizers = { # @formatter:off
        [:req] => ->(type, name) { (name || -> { result.__send__(:name) }.call).to_s },
        [:key, :keyrest] => ->(type, name) { result.keyrest? ? nil : '**kwargs' },
        [:opt, :rest] => ->(type, name) { result.rest? ? nil : '*args' },
        [:blk] => ->(type, name) { "&#{name}" },
        [:keyreq] => ->(type, name) { "#{name}:" }
      } # @formatter:on

      {}.tap do |r|
        parameterizers.each do |k, v|
          k.each { |key| r[key] = v }
        end
      end
    end
    # rubocop:enable Metrics/MethodLength, Layout/LineLength
  end

  # Generate a new name.
  #
  # @return [String]
  def name(count = 1)
    "st#{count}".tap do |str|
      return to_a.include?(str) ? name(count + 1) : str
    end
  end

  # @param [Symbol] type
  # @param [Symbol|nil] name
  def parameterize(type, name)
    return parameterizers[type].call(type, name) if parameterizers.key?(type)

    # rubocop:disable Style/RedundantException
    raise RuntimeError, "Unsupported type #{type.inspect}"
    # rubocop:enable Style/RedundantException
  end
end
