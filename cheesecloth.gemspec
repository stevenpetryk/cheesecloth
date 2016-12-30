# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cheesecloth/version"

Gem::Specification.new do |spec|
  spec.name          = "cheesecloth"
  spec.version       = CheeseCloth::VERSION
  spec.authors       = ["Steven Petryk"]
  spec.email         = ["me@stevenpetryk.com"]

  spec.summary       = "Take the boilerplate out of filtering a collection based on params."
  spec.description   = <<-DESCRIPTION
    Dealing with filtering based on params in Rails is a pain. CheeseCloth is designed to make it
    simple.
  DESCRIPTION
  spec.homepage      = "https://github.com/stevenpetryk/"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 5.0"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
