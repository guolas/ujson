#!/usr/bin/env ruby
# encoding: utf-8

require 'test/unit'
require 'ujson.rb'

class TestJSONFixtures < Test::Unit::TestCase
  def setup
    fixtures = File.join(File.dirname(__FILE__), 'fixtures/*.json')
    passed, failed = Dir[fixtures].partition { |f| f['pass'] }
    @passed = passed.inject([]) { |a, f| a << [ f, File.read(f) ] }.sort
    @failed = failed.inject([]) { |a, f| a << [ f, File.read(f) ] }.sort
  end

  def test_passing
    for name, source in @passed
      begin
        assert Parser.new(source).parse,
          "Did not pass for fixture '#{name}': #{source.inspect}"
      rescue => e
        warn "\nCaught #{e.class}(#{e}) for fixture '#{name}': #{source.inspect}\n#{e.backtrace * "\n"}"
        raise e
      end
    end
  end

  def test_failing
    for name, source in @failed
      assert_raises(FormatError, JSON::NestingError,
        "Did not fail for fixture '#{name}': #{source.inspect}") do
        Parser.new(source).parse
      end
    end
  end
end
