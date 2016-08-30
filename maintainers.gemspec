# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'maintainers/version'

Gem::Specification.new do |spec|
  spec.name          = "maintainers"
  spec.version       = Maintainers::VERSION
  spec.authors       = ["Kylo Ginsberg"]
  spec.email         = ["kylo@puppet.com"]

  spec.summary       = %q{A gem for maintaining MAINTAINERS files}
  spec.homepage      = "https://github.com/kylog/maintainers"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   << 'maintainers'
  spec.require_paths = ['lib']

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_runtime_dependency     'json-schema', '~> 2.6'
end
