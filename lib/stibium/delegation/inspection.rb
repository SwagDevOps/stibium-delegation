# frozen_string_literal: true

# Copyright (C) 2017-2020 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../delegation'

# @qpi private
#
# Method inpection
#
# @see https://ruby-doc.org/core-2.5.3/Method.html
class Stibium::Delegation::Inspection
  # @param [Symbol] method
  def call(method:, &block)
    return ['*args', '&block'] unless block

    # @formatter:off
    block.call
         .yield_self { |r| r.is_a?(Class) || r.is_a?(Module) ? { type: r } : r }
         .to_h
         .merge({ method: method })
         .yield_self { |kwargs| self.scan(**kwargs) }
    # @formatter:on
  end

  # @param [Class|Module] type
  # @param [Symbol] method
  # @param [Boolean] instance
  def scan(type:, method:, instance: true)
    type.public_send("#{instance ? :instance_ : nil}method", method)
        .parameters
        .each_with_index
        .map { |row, i| parameterize(*row.concat([i])) }
        .uniq
  end

  protected

  # @param [Symbol] type
  # @param [Symbol] name
  # @param [Integer] position
  def parameterize(type, name, position = 0)
    return (name || "st#{position + 1}").to_s if :req == type
    return '**kwargs' if [:key, :keyrest].include?(type)
    return "*#{name}" if :rest == type
    return "&#{name}" if :blk == type
    return "#{name}:" if :keyreq == type

    # rubocop:disable Style/RedundantException
    raise RuntimeError, "Unsupported type #{type.inspect}"
    # rubocop:enable Style/RedundantException
  end
end
