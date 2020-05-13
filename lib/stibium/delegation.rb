# frozen_string_literal: true

# Copyright (C) 2017-2020 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../stibium-delegation'

# Provides a ``delegate`` class method
# to expose contained objects' public methods.
#
# @see https://apidock.com/rails/Module/delegate
# @see https://github.com/rails/rails/blob/3a38c0721133175b2bd0073ec1e7a84b9c6e178c/activesupport/lib/active_support/core_ext/module/delegation.rb#L18
module Stibium::Delegation
  # @formatter:off
  {
    VERSION: 'version',
    Inspection: 'inspection',
    Methodifier: 'methodifier',
  }.each { |s, fp| autoload(s, "#{__dir__}/delegation/#{fp}") } # @formatter:on

  def self.included(base)
    base.extend(ClassMethods)
  end

  # Class methods
  module ClassMethods
    protected

    # Provides a ``delegate`` class method
    # to expose contained objects' public methods.
    #
    # @return [Hash{Symbol => String}]
    def delegate(*methods, to:, visibility: :public, prefix: nil, &block)
      methods.map(&:to_sym).map do |method|
        # rubocop:disable Layout/LineLength
        Stibium::Delegation::Methodifier.new(method: method, &block).yield_self do |m|
          [method] << m.call(to: to, visibility: visibility, prefix: prefix).freeze.tap do |code|
            self.class_eval(code, __FILE__, __LINE__)
          end
        end
        # rubocop:enable Layout/LineLength
      end.to_h.freeze
    end
  end
end
