# coding: utf-8
# rubocop:disable RegexpLiteral

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'iriri'
  spec.version       = '0.0.1'
  spec.authors       = ['Yuji Nakayama']
  spec.email         = ['nkymyj@gmail.com']
  spec.summary       = 'An IR remote controller framework'
  spec.description   = spec.summary
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'serialport', '~> 1.3'
  spec.add_runtime_dependency 'pi_piper'
  spec.add_runtime_dependency 'diff-lcs', '~> 1.2'
  spec.add_runtime_dependency 'rainbow', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 1.6'
end
