# frozen_string_literal: true

Class.new do
  autoload(:FileUtils, 'fileutils')

  def initialize
    @fs = FileUtils
  end

  include Stibium::Delegation

  delegate(:touch, to: '@fs') do
    { type: FileUtils, instance: false }
  end
end
