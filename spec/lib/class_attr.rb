# frozen_string_literal: true

# Copyright (C) 2017-2020 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

module ClassAttr
  def self.included(base)
    base.extend(ClassMethods)
  end

  # Class methods
  module ClassMethods
    protected

    def class_attr(name)
      # @formatter:off
      ([
        'class << self',
        '  attr_reader :%<attr_name>s',
        '  protected',
        '  attr_writer :%<attr_name>s',
        'end', # @formatter:on
      ].join("\n") % { attr_name: name }).tap do |code|
        self.class_eval(code, __FILE__, __LINE__)
      end
    end
  end
end
