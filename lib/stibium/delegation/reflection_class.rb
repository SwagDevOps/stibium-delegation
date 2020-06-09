# frozen_string_literal: true

# Copyright (C) 2017-2020 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../delegation'

# Reflection is executed on the class including the delegation module.
#
# @api private
class Stibium::Delegation::ReflectionClass
  # @return [Class]
  attr_reader :subject

  # @param [Class] subject
  #
  # @raise [NoMethodError]
  def initialize(subject)
    subject.allocate.yield_self { @subject = subject }
  end

  # @return [Object]
  def reflect
    subject.allocate
  end

  # Ensure given symbol is defined.
  #
  # @raise [Stibium::Delegation::Errors::Error]
  # @return [Symbol] possible values are: variable|constant|method
  def ensure_symbol!(symbol)
    self.class.__send__(:guess_symbol_type, symbol).tap do |k|
      ensure_resolvable!(symbol) unless :variable == k
    end
  end

  # Ensure given `name is defined on ``subject`` as a method or a constant.
  #
  # @param [String|Symbol] name
  #
  # @raise [NoMethodError]
  # @return [Boolean]
  def ensure_resolvable!(name)
    return true if reflect.respond_to?(name, true)

    return true if subject.const_defined?(name, true)

    raise Stibium::Delegation::Errors::NoMethodError.new(type: reflect, name: name)
  end

  class << self
    protected

    # @api private
    def guess_symbol_type(symbol)
      # class or instance variable
      return :variable if symbol.to_s =~ /^@/

      # @see https://github.com/rubocop-hq/ruby-style-guide#screaming-snake-case
      return :constant if symbol.to_s =~ /^[A-Z]+([A-Z]|[0-9]|_)*/u

      return :method
    end
  end
end
