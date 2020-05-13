# frozen_string_literal: true

Class.new do
  include ClassAttr
  include Stibium::Delegation

  def initialize
    Class.new do
      def hello
        :hello
      end

      def goodbye
        :goodbye
      end
    end.tap do |klass|
      @greeter = klass.new
    end
  end

  delegate(:hello, :goodbye, to: :'@greeter').tap do |res|
    class_attr(:delegation)
    # noinspection RubyResolve
    self.delegation = res
  end
end
