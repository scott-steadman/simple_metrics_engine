require 'test/test_helper'
require 'sme/extensions/hash'

module Sme::Extensions
  class HashTest < ActiveSupport::TestCase

    test 'to_tree with integer values' do
      expected = {
        'one' => {
          'one' => {
            'one' => 111,
            'two' => 112,
          },
          'two' => {
            'one' => 121,
            'two' => 122,
          },
        },
        'two' => {
          'one' => 21,
          'two' => 22,
        },
      }

      source = {
        'one/one/one' => 111,
        'one/one/two' => 112,
        'one/two/one' => 121,
        'one/two/two' => 122,
        'two/one'     => 21,
        'two/two'     => 22,
      }
      assert_equal expected, source.to_tree
    end

    test 'to_tree with hash values' do
      expected = {
        'one' => {
          'one' => {
            'one' => 111,
            'two' => 112,
          },
          'two' => {
            'one' => 121,
            'two' => 122,
          },
        },
        'two' => {
          'one' => 21,
          'two' => 22,
        },
      }

      source = {
        'one/one' => {
          'one' => 111,
          'two' => 112,
        },
        'one/two' => {
          'one' => 121,
          'two' => 122,
        },
        'two' => {
          'one' => 21,
          'two' => 22,
        },
      }
      assert_equal expected, source.to_tree
    end


  end
end
