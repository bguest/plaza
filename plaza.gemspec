# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'plaza/version'

Gem::Specification.new do |spec|
  spec.name          = "plaza"
  spec.version       = Plaza::VERSION
  spec.authors       = ["VMC Engineering"]
  spec.email         = ["eng@visiblemeasures.com", "benguest@gmail.com"]
  spec.summary       = %q{Client for rest_area gem}
  spec.description   = %q{Rest client for that works in conjuntion with rest_area gem}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec', '~> 2.99'
  spec.add_development_dependency 'mocha', '~> 1.1'

  spec.add_runtime_dependency 'faraday', '~> 0.9.0'
  spec.add_runtime_dependency 'faraday_middleware', '~>0.9.1'
  spec.add_runtime_dependency 'faraday-http-cache', '~>1.1.0'
  spec.add_runtime_dependency 'faraday-conductivity', '~>0.3.1'
  spec.add_runtime_dependency "virtus", '~> 1.0'
end
