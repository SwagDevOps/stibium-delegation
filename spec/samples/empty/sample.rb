# frozen_string_literal: true

# This class does not delegate by itslef.
#
# Delegation will be callled on ``#failed?`` protected method
# in example in order to trigger
# ``Stibium::Delegation::Errors::NoPublicMethodError`` error.
Class.new do
  include ClassAttr
  include Stibium::Delegation

  class_attr(:delegation)
  # noinspection RubyResolve
  self.delegation = {}

  Class.new do
    protected

    # @return [Boolean]
    def failed?
      !![true, false].sample
    end
  end.tap do |status_class|
    self.singleton_class.define_method(:status_class) { status_class }
  end

  attr_reader :status

  def initialize
    @status = self.class.__send__(:status_class)
  end
end
