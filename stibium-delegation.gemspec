# frozen_string_literal: true
# vim: ai ts=2 sts=2 et sw=2 ft=ruby
# rubocop:disable all

Gem::Specification.new do |s|
  s.name        = "stibium-delegation"
  s.version     = "0.0.1"
  s.date        = "2020-02-05"
  s.summary     = "Delegation pattern implementation"
  s.description = "Provides a delegate class method to expose contained objects methods"

  s.licenses    = ["GPL-3.0"]
  s.authors     = ["Dimitri Arrigoni"]
  s.email       = "dimitri@arrigoni.me"
  s.homepage    = "https://github.com/SwagDevOps/stibium-delegation"

  # MUST follow the higher required_ruby_version
  # requires version >= 2.3.0 due to safe navigation operator &
  # requires version >= 2.5.0 due to yield_self
  s.required_ruby_version = ">= 2.5.0"
  s.require_paths = ["lib"]
  s.files         = [
    ".yardopts",
    "lib/stibium-delegation.rb",
    "lib/stibium/delegation.rb",
    "lib/stibium/delegation/errors.rb",
    "lib/stibium/delegation/inspection.rb",
    "lib/stibium/delegation/inspection/result.rb",
    "lib/stibium/delegation/methodifier.rb",
    "lib/stibium/delegation/reflection_class.rb",
    "lib/stibium/delegation/version.rb",
    "lib/stibium/delegation/version.yml",
  ]

  
end

# Local Variables:
# mode: ruby
# End:
