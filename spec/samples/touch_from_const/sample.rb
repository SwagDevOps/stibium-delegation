# frozen_string_literal: true

Class.new do
  autoload(:FileUtils, 'fileutils')

  include ClassAttr
  include Stibium::Delegation

  self.const_set(:FS, FileUtils)

  delegate(:touch, to: :FS) do
    { type: self.const_get(:FS), instance: false }
  end.tap do |res|
    class_attr(:delegation)
    # noinspection RubyResolve
    self.delegation = res
  end
end
