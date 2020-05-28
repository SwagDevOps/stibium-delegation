# frozen_string_literal: true

# Copyright (C) 2017-2020 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../delegation'

# @api private
#
# Method inpection
#
# @see https://ruby-doc.org/core-2.5.3/Method.html
class Stibium::Delegation::Inspection
  # @formatter:off
  {
    Result: 'result',
  }.each { |s, fp| autoload(s, "#{__dir__}/inspection/#{fp}") } # @formatter:on

  def call(method, &block)
    return default_result unless block

    # @formatter:off
    block.call
         .yield_self { |r| r.is_a?(Class) || r.is_a?(Module) ? { type: r } : r }
         .to_h
         .merge({ method: method })
         .yield_self { |kwargs| self.scan(**kwargs) }
    # @formatter:on
  end

  protected

  # @return [Result]
  attr_reader :result

  def default_result
    Result.new.tap do |res|
      [[:rest, nil], [:blk, 'block']].each { |r| res.add(*r) }
    end
  end

  # Scan given ``type`` for public methods named ``method``.
  #
  # @param [Class|Module] type
  # @param [Symbol] method
  # @param [Boolean] instance
  #
  # @raise [Stibium::Delegation::Errors::NoPublicMethodError]
  def scan(type:, method:, instance: true)
    unless (instance ? type.allocate : type).respond_to?(method.to_sym)
      Stibium::Delegation::Errors::NoPublicMethodError.new(type: type, name: method).tap { |e| raise e }
    end

    Result.new.tap do |result|
      type.public_send("#{instance ? :instance_ : nil}method", method).parameters.each do |parameters|
        result.add(*parameters)
      end
    end
  end
end
