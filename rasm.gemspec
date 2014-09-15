# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rasm/version'

Gem::Specification.new do |spec|
  spec.name          = 'rasm'
  spec.version       = Rasm::VERSION
  spec.authors       = ['James Zhan']
  spec.email         = ['zhiqiangzhan@gmail.com']
  spec.summary       = %q{A x86 assembler}
  spec.description   = %q{A x86 assembler implemented by Ruby.}
  spec.homepage      = 'https://github.com/jameszhan/rasm'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
end
