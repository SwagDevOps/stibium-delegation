# frozen_string_literal: true

require_relative '../dev/project'

Dir.glob("#{__dir__}/../lib/*.rb").map { |req| require req }

if Gem::Specification.find_all_by_name('sys-proc').any?
  require 'sys/proc'

  Sys::Proc.progname = 'rspec'
end

# @formmatter:off
[
  :constants,
  :configure,
].each do |req|
  require_relative '%<dir>s/%<req>s' % {
    dir: __FILE__.gsub(/\.rb$/, ''),
    req: req.to_s,
  }
end
# @formmatter:on

# Load files in lib - (specific to this test suite) -----------------
Dir.glob("#{__dir__}/lib/*.rb").shuffle.map { |req| require req }
