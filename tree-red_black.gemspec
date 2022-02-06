# frozen_string_literal: true

require_relative 'lib/tree/red_black/version'

Gem::Specification.new do |spec|
  spec.name          = 'tree-red_black'
  spec.version       = Tree::RedBlack::VERSION
  spec.authors       = ['Andrew L. Moore']
  spec.email         = ['SlewSys@gmail.com']

  spec.summary       = 'Pure-Ruby implementation of Red-Black tree'
  spec.description   = 'Pure-Ruby implemention of Red-Black tree with O(log n) search, insert and delete operations.'
  spec.homepage      = 'https://github.com/slewsys/tree-red_black'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  # spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  # spec.metadata['changelog_uri'] = %{TODO: Put your gem's CHANGELOG.md URL here.}

  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.3', '>= 2.0.1'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec-expectations', '~> 3.10'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'iruby', '~> 0.7'
  spec.add_development_dependency 'solargraph', '~> 0.44'
end
