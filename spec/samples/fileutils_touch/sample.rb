# frozen_string_literal: true

Class.new do
  autoload(:FileUtils, 'fileutils')

  def initialize
    @fs = FileUtils
  end

  include ClassAttr
  include Stibium::Delegation

  delegate(:touch, to: '@fs') do
    { type: FileUtils, instance: false }
  end.tap do |res|
    class_attr(:delegation)
    # noinspection RubyResolve
    self.delegation = res
  end
end
