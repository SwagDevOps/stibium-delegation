# frozen_string_literal: true

# Copyright (C) 2017-2020 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../delegation'

# @api private
class Stibium::Delegation::Methodifier
  # @return [Symbol]
  attr_reader :method

  # @param [String|Symbol] method
  def initialize(method:, &block)
    @method = method.freeze
    @inspection = Stibium::Delegation::Inspection.new.call(method, &block)
  end

  # rubocop:disable Metrics/MethodLength

  # @param [String|Symbol] to
  # @param [String|Symbol] visibility
  # @param [String|nil] prefix
  #
  # @return [String]
  def call(to:, visibility: :public, prefix: nil)
    # @formatter:off
    [
      '%<visibility>s def %<method>s(%<signature>s)',
      '  %<to>s.public_send(%<call>s)',
      'end',
    ].join("\n") % {
      visibility: visibility,
      method: [prefix, method].compact.join('_'),
      signature: inspection.to_s,
      to: to,
      call: [method.inspect].concat(inspection.parameters).join(', ')
    }
    # @formatter:on
  end

  # rubocop:enable Metrics/MethodLength

  protected

  # @return [Stibium::Delegation::Inspection::Result]
  attr_reader :inspection
end
