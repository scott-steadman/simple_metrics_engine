require 'test/test_helper'

class Sme::LogTest < ActiveRecord::TestCase

  test 'create' do
    attrs = {:event => 'foo', :foo => false}
    log = Sme::Log.create!(attrs)
    assert_equal 'foo', log.event, 'event data should be extracted to field'
    assert_nil log.user_id
    assert_equal attrs.to_json, log._data, 'original attributes should be stored in _data'
  end

  test 'create converts event to string' do
    assert_equal 'foo', Sme::Log.create!(:event => :foo).event
  end

end
