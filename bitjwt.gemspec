$:.push File.expand_path("../lib", __FILE__)
require 'bitjwt/version'

Gem::Specification.new do |s|
  s.name        = 'bitjwt'
  s.version     = BitJWT::VERSION
  s.date        = '2016-06-16'
  s.summary     = 'Bitcoin JWT implementation'
  s.description = 'JWT protocol implementation using Bitcoin secp256k1'
  s.authors     = ['Federico Barbazza']
  s.email       = 'federico.barbazza@gmail.com'
  s.files       = ['lib/bitjwt.rb']
  s.homepage    =
    'http://rubygems.org/gems/bitjwt'
  s.license       = 'MIT'
  s.files         = `git ls-files -z`.split("\x0")
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_dependency 'ffi', '~> 1.9'
  s.add_dependency 'bitcoin-ruby', '0.0.8'
  s.add_dependency 'excon', '~> 0.49'
  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'rspec-mocks', '~> 3.4'
  s.add_development_dependency 'webmock', '~> 2.1'
end
