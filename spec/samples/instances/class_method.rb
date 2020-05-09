# frozen_string_literal: true

Class.new do
  include Stibium::Delegation

  def initialize
    Class.new do
      class << self
        def class_method
          true
        end
      end
    end.tap do |klass|
      @inner_class = klass
    end
  end

  delegate(:class_method, to: :inner_class)

  protected

  attr_reader :inner_class
end
