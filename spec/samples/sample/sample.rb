# frozen_string_literal: true

Class.new do
  Class.new do
    # Concat given args in an Array
    #
    # @param [Object] foo
    # @param [Object] bar
    #
    # @return [Object]
    def greatest(foo, bar)
      return [foo].concat([bar]).max
    end

    # Concat given args with given separator
    #
    # @return [String]
    def concat(*strings, separator: ' ')
      return strings.join(separator)
    end

    def auth(username:, password:)
      autoload(:Base64, 'base64')

      Base64.encode64("#{username}:#{password}")
    end

    # Fibonnaci can pass results back one at a time
    #
    # Sample of use:
    #
    # ```
    # fibonacci(15) { |i| puts i }
    # # [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987]
    # ```
    #
    # @return [Array<Integer>]
    # @see http://www.wellho.net/resources/ex.php4?item=r104/yrb
    # @see https://en.wikipedia.org/wiki/Fibonacci_number
    def fibonacci(limit)
      current = previous = 1
      (0..limit).map do |i|
        if i > 1
          temp = current
          current += previous
          previous = temp
        end

        current.tap { yield current if block_given? }
      end
    end
  end.tap do |utils_klass|
    self.singleton_class.define_method(:utils_klass) { utils_klass }
  end

  def initialize
    @kw = self.class.__send__(:utils_klass).new
  end

  include ClassAttr
  include Stibium::Delegation

  # rubocop:disable Layout/LineLength
  delegate(:concat, :greatest, :auth, :fibonacci, to: :'@utils') { __send__(:utils_klass) }.tap do |res|
    class_attr(:delegation)
    # noinspection RubyResolve
    self.delegation = res
  end
  # rubocop:enable Layout/LineLength
end
