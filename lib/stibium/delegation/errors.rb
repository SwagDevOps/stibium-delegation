# frozen_string_literal: true

# Copyright (C) 2017-2020 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../delegation'

# Errors module
module Stibium::Delegation::Errors
  # Parameter inspection error
  class UnsupportedParameterTypeError < RuntimeError
    # @type [Symbol|String]
    attr_reader :type

    # @param [Symbol|String] type
    def initialize(type:)
      @type = type.to_sym

      super("Unsupported type #{type.inspect}")
    end
  end

  # Method inspection error
  class NoPublicMethodError < RuntimeError
    # @type [Class|Module|Object]
    attr_reader :type

    # @type [Symbol]
    attr_reader :method

    # @param [Class|Module|Object] type
    # @param [Symbol|String] method
    def initialize(type:, method:)
      @type = type
      @method = method.to_sym

      super("method `#{method}' for #{type} is not a public method")
    end
  end
end
