source 'https://rubygems.org'

gemspec

if path = ENV['test-unit']
  gem 'test-unit', :path => path
elsif version = ENV['TEST_UNIT']
  gem 'test-unit', version
end
