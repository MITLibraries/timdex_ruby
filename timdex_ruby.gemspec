# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'timdex/version'

Gem::Specification.new do |spec|
  spec.name          = 'timdex-ruby'
  spec.version       = Timdex::VERSION
  spec.authors       = ['Jeremy Prevost']
  spec.email         = ['jprevost@mit.edu']

  spec.summary       = "Ruby wrapper for MIT Libraries' TIMDEX Discovery API"
  spec.homepage      = 'https://github.com/MITLibraries/timdex_ruby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2'
  spec.add_development_dependency 'byebug', '~> 5.0'
  spec.add_dependency 'jwt'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_dependency 'faraday', '~> 0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'timecop'
  spec.add_development_dependency 'vcr'
end
