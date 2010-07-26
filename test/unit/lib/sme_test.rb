require 'test/test_helper'

class SmeTest < ActiveSupport::TestCase

  test 'configure yeields a config' do
    Sme.configure do |config|
      assert_equal Sme::Config, config.class
    end
  end

end # class RollupTest
