# frozen_string_literal: true

# Copyright (C) 2017-2020 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../stibium-delegation'

# Provides a ``delegate`` class method to expose contained objects methods.
#
# @api private
#
# @see https://apidock.com/rails/Module/delegate
# @see https://github.com/rails/rails/blob/3a38c0721133175b2bd0073ec1e7a84b9c6e178c/activesupport/lib/active_support/core_ext/module/delegation.rb#L18
module Stibium::Delegation
  # @formatter:off
  {
    VERSION: 'version',
  }.each { |s, fp| autoload(s, "#{__dir__}/delegation/#{fp}") }
  # @formatter:on

  def self.included(base)
    base.extend(ClassMethods)
  end

  # Class methods
  module ClassMethods
    protected

    def delegate(*methods, to:, type: nil, visibility: :public) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      inspection = lambda do |klass, method_name|
        klass.instance_method(method_name).parameters.each_with_index.map do |row, i| # rubocop:disable Layout/LineLength
          lambda do |param_type, param_name = nil|
            return (param_name || "st#{i}").to_s if :req == param_type
            return "*#{param_name}" if :rest == param_type
            return "&#{param_name}" if :blk == param_type
            return ":#{param_name}" if :key == param_type
          end.call(*row)
        end
      end

      # rubocop:disable Layout/LineLength
      methods.map(&:to_sym).each do |method_name|
        (type ? inspection.call(type, method_name) : ['*args', '&block']).tap do |params|
          # rubocop:disable Naming/HeredocDelimiterNaming
          self.class_eval <<-EOL, __FILE__, __LINE__ + 1
            #{visibility} def #{method_name}(#{params.join(', ')})
              #{to}.public_send(#{[method_name.inspect].concat(params).join(', ')})
            end
          EOL
          # rubocop:enable Naming/HeredocDelimiterNaming
        end
      end
      # rubocop:enable Layout/LineLength
    end
  end
end
