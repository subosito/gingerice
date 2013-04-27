# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gingerice/version'

Gem::Specification.new do |spec|
  spec.name          = "gingerice"
  spec.version       = Gingerice::VERSION
  spec.authors       = ["Alif Rachmawadi"]
  spec.email         = ["subosito@gmail.com"]
  spec.description   = %q{Corrects spelling and grammar mistakes based on the context of complete sentences.}
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/subosito/gingerice"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "addressable"
end
