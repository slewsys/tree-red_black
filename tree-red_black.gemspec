# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tree/red_black/version'

Gem::Specification.new do |spec|
  spec.name          = "tree-red_black"
  spec.version       = Tree::RedBlack::VERSION
  spec.authors       = ["Andrew L. Moore"]
  spec.email         = ["SlewSys@gmail.com"]

  spec.summary       = %q{Pure-Ruby implementation of Red-Black tree}
  spec.description   = %q{Pure-Ruby implemention of Red-Black tree, a self-balancing binary search tree with O(log n) search, insert and delete operations.}
  spec.homepage      = "https://github.com/slewsys/tree-red_black"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0", ">= 2.0.1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec-expectations", "~> 3.8"
  spec.add_development_dependency "rspec", "~> 3.8"
end
