# frozen_string_literal: true

Class.new do
  class << self
    protected

    def sample_klass
      Class.new do
        def sample(arg, foo:)
          return [arg].concat([foo])
        end
      end
    end
  end

  def initialize
    @kw = self.class.__send__(:sample_klass).new
  end

  include Stibium::Delegation

  delegate(:sample, to: :'@kw') { __send__(:sample_klass) }
end
