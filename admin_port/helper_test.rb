require 'test/unit'
require './helper'

class HelperTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Fake test
  def test_generate_token
    assert_equal Helper::TOKEN_LENGTH, Helper.generate_token.length
    first = Helper.generate_token
    second = Helper.generate_token
    assert_not_equal first, second
  end
end