# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jkf/version'

Gem::Specification.new do |spec|
  spec.name = 'jkf'
  spec.version = Jkf::VERSION
  spec.authors = %w[iyuuya gemmaro]
  spec.email = %w[i.yuuya@gmail.com gemmaro.dev@gmail.com]

  spec.summary = 'jkf/csa/kif/ki2 parser and converter'
  spec.description = 'converter/parser of records of shogi'
  spec.homepage = 'https://github.com/gemmaro/ruby-json-kifu-format'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
