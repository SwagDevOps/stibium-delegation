# frozen_string_literal: true

# Copyright (C) 2017-2020 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../delegation'

# Errors module
module Stibium::Delegation::Errors
  # @abstract
  class Error < ::RuntimeError
  end

  # Parameter inspection error
  class UnsupportedParameterTypeError < Error
    # @type [Symbol|String]
    attr_reader :type

    # @param [Symbol|String] type
    def initialize(type:)
      @type = type.to_sym
    end

    def to_s
      "Unsupported type #{type.inspect}"
    end
  end

  # @abstract
  class MiisingSymbolError < Error
    # @type [Class|Module|Object]
    attr_reader :type

    # @type [Symbol]
    attr_reader :name

    # @param [Class|Module|Object] type
    # @param [Symbol|String] method
    def initialize(type:, name:)
      @type = type
      @name = name.to_sym
    end
  end

  # Method reflection error
  class NoConstantError < MiisingSymbolError
    def to_s
      "uninitialized constant #{name} for #{type}"
    end
  end

  # Method reflection error
  class NoMethodError < Error
    def to_s
      "undefined method `#{name}' for #{type}"
    end
  end

  # Method inspection error
  class NoPublicMethodError < MiisingSymbolError
    def to_s
      "method `#{name}' for #{type} is not a public instance method"
    end
  end
end
