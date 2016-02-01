begin
  require 'test/unit/version'
  puts "using Test::Unit::VERSION = #{Test::Unit::VERSION}" if $VERBOSE
rescue LoadError => e
  require('rubygems') && retry
  fail "`bundle install` to install Test::Unit 2.x (#{e.inspect})"
end
$LOAD_PATH.unshift File.expand_path('../lib', File.dirname(__FILE__))
require 'test/unit/context'