# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name          = 'test-unit-context'
  gem.authors       = ['Karol Bucek']
  gem.email         = ['self@kares.org']
  gem.licenses      = ['Apache-2.0']

  path = File.expand_path("lib/test/unit/context/version.rb", File.dirname(__FILE__))
  gem.version       = File.read(path).match( /.*VERSION\s*=\s*['"](.*)['"]/m )[1]

  gem.summary       = %q{Context for Test::Unit (2.x)}
  gem.description   = %q{Makes Test::Unit::TestCases 'contextable' and thus much
easier to read and write. If you've seen RSpec than it's the very same 'context
do ... end' re-invendet for Test::Unit. Inspired by gem 'context' that does a
similar job for the 'old' Test::Unit bundled with Ruby 1.8.x standard libraries.}
  gem.homepage      = "https://github.com/kares/test-unit-context"

  gem.require_paths = ["lib"]
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test}/*`.split("\n")

  gem.extra_rdoc_files = %w[ README.md LICENSE ]

  gem.add_dependency 'test-unit', '>= 2.4.0'
  gem.add_development_dependency 'rake'
end
