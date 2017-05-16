# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gop_data_trust_adapter/version'

Gem::Specification.new do |spec|
  spec.name          = "gop_data_trust_adapter"
  spec.date          = '2015-05-14'
  spec.version       = GopDataTrustAdapter::VERSION
  spec.authors       = ["Andrew Rove"]
  spec.email         = ["andrew.m.rove@gmail.com"]
  spec.summary       = %q{GOP Data Trust's Direct API Adapter.}
  spec.description   = %q{An ActiveRecord like adapter for the GOP Data Trust's Direct API. https://lincoln.gopdatatrust.com/v2/docs/}
  spec.homepage      = "http://rubygems.org/gems/gop_data_trust_adapter"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.2.0'

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 11"
  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "mocha"

  spec.add_dependency 'httparty', ">= 0.10.0"
end
