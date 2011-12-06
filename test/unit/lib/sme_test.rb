require 'test/test_helper'

class SmeTest < ActiveSupport::TestCase

  class FooWrapper
    def initialize(logger)
      @logger = logger
    end

    def call(event_hash)
      event_hash[:foo] = 'foo'
      @logger.call(event_hash)
    end
  end

  def bar_wrapper(event_hash)
    event_hash.merge(:bar => 'bar')
  end

  test 'configure yeields a config' do
    Sme.configure do |config|
      assert_equal Sme::Config, config.class
    end
  end

  test 'log with event' do
    log = Sme.log(:foo)
    assert_equal 'foo', log.event
  end

  test 'log with event and hash' do
    log = Sme.log(:foo, :foo => 'bar')
    assert_equal 'foo', log.event
    assert_equal({:event => 'foo', :foo => 'bar'}.to_json, log._data)
  end

  test 'log with hash' do
    log = Sme.log(:event => :foo, :foo => 'bar')
    assert_equal 'foo', log.event
    assert_equal({:event => 'foo', :foo => 'bar'}.to_json, log._data)
  end

  test 'log failure' do
    assert_raise ActiveRecord::StatementInvalid do
      log = Sme.log!(nil)
    end
  end

  test 'wrap' do
    Sme.wrap!(FooWrapper, method(:bar_wrapper))
    results = JSON.parse(Sme.log(:event)._data)
    assert_equal 'foo', results['foo'], 'FooWrapper class failed'
    assert_equal 'bar', results['bar'], 'bar_wrapper method failed'
    assert_equal 'event', results['event'], 'event should be set'

    Sme.instance_variable_set(:@wrapper_chain, nil)
  end

  test 'wrap raises ArgumentError' do
    assert_raise ArgumentError do
      Sme.wrap!(:foo)
    end
  end

end # class SmeTest
