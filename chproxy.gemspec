# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chproxy/version'

Gem::Specification.new do |spec|
  spec.name          = 'chproxy'
  spec.version       = Chproxy::VERSION
  spec.authors       = ['Lukas Westermann']
  spec.email         = ['lukas.westermann@gmail.com']
  spec.license       = 'MIT'

  spec.summary       = 'The simple proxy settings manager.'
  spec.description   = "chproxy manages your proxy settings.\n\n" \
                       'It automatically updates the proxy configuration for several command line tools ' \
                       'like gradle or maven, based on the proxy, http_proxy and other environment variables.'
  spec.homepage      = 'https://github.com/lwe/chproxy'

  spec.files         = Dir['lib/**/*.rb'] + %w[exe/chproxy chproxy.gemspec README.md LICENSE]
  spec.bindir        = 'exe'
  spec.executables   = %w[chproxy]
  spec.require_paths = %w[lib]

  spec.add_runtime_dependency 'thor', '~> 0.20'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake',    '~> 10.0'
  spec.add_development_dependency 'rspec',   '~> 3.0'
  spec.add_development_dependency 'fakefs',  '~> 0.11'
  spec.add_development_dependency 'rubocop', '~> 0.50.0'

  spec.required_ruby_version = '>= 2.0.0'
end
