# frozen_string_literal: true

Class.new do
  autoload(:FileUtils, 'fileutils')

  include ClassAttr
  include Stibium::Delegation

  Module.new { self.const_set(:FS, FileUtils) }.tap { |klass| self.const_set(:InnerConst, klass) }

  delegate(:touch, to: 'InnerConst::FS') do
    { type: self.const_get(:InnerConst).const_get(:FS), instance: false }
  end.tap do |res|
    class_attr(:delegation)
    # noinspection RubyResolve
    self.delegation = res
  end
end
