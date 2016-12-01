# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gestalt/version'

Gem::Specification.new do |spec|
  spec.name          = "gestalt"
  spec.version       = Gestalt::VERSION
  spec.authors       = ["James Dabbs"]
  spec.email         = ["jamesdabbs@gmail.com"]

  spec.summary       = "Quick-and-dirty functional service objects"
  spec.description   = spec.summary
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "concurrent-ruby", "~> 1"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 11.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-coverage", "~> 0.1"
end
