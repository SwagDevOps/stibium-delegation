# frozen_string_literal: true

# Copyright (C) 2017-2020 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../inspection'

# Describe the inspection result.
#
# @api private
class Stibium::Delegation::Inspection::Result
  def initialize
    @parameterizers = self.class.__send__(:parameterizers_for, self).freeze
    @state = {}.freeze
  end

  # Add new parameter with given type and name.
  #
  # @param [Symbol] type
  # @param [Symbol|nil] name
  #
  # @return [self]
  def add(type, name)
    self.tap do
      self.parameterize(type, name).tap do |res|
        @state.dup.tap do |state|
          # @formatter:off
          state[state.values.length] = [
            [type, name].map { |v| v&.to_sym }.freeze,
            res.freeze
          ].freeze
          # @formatter:on
        end.tap { |state| @state = state.freeze }
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

  # @return [Array<String>]
  def to_a
    Hash[state.sort].values.map(&:last).yield_self do |values|
      values.compact.map { |v| v.to_s.freeze }.freeze
    end
  end

  # Get parameters (usable for method call).
  #
  # @return [Array<String>]
  def parameters
    to_a.map { |str| str.gsub(/:$/, '').freeze }.freeze
  end

  protected

  # Get parameterizers.
  #
  # @see .parameterizers_for
  #
  # @return [Hash{Symbol => Proc}]
  attr_reader :parameterizers

  # Internal state, evolving through successive ``#add`` calls.
  #
  # @return [Hash{Integer => Array}]
  #
  # @see #add
  #
  # Hash key is the position for parameter.
  # Fisrt value, are the parameters used by parameterizers lambda call;
  # last value is the parameterizered value (parameterizers call result).
  attr_reader :state

  class << self
    protected

    # rubocop:disable Metrics/MethodLength

    # Get parameterizers for given intsance.
    #
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
          k.each { |key| r[key.freeze] = v.freeze }
        end
      end.freeze
    end
    # rubocop:enable Metrics/MethodLength
  end

  # Generate a new parameter name.
  #
  # @return [String]
  def name(count = 1)
    "st#{count}".yield_self { |str| to_a.include?(str) ? name(count + 1) : str }
  end

  # @param [Symbol] type
  # @param [Symbol|nil] name
  def parameterize(type, name)
    return parameterizers[type].call(type, name) if parameterizers.key?(type)

    raise Stibium::Delegation::Errors::UnsupportedParameterTypeError, type
  end
end
