#!/usr/bin/env ruby

require 'test/unit'
require 'sentence'

class TestMovingSlice < Test::Unit::TestCase
  using Sentence

  A = [1, 2, 3, 4, 5].freeze

  def test_to_a
    a3 = A.moving_slice(3).to_a
    a3_expected = [[1, 2, 3], [2, 3, 4], [3, 4, 5]]
    assert_equal a3_expected, a3
  end

  def test_method
    a3_sum = A.moving_slice(3, &:sum).to_a
    a3_sum_expected = [(1 + 2 + 3), (2 + 3 + 4), (3 + 4 + 5)]
    assert_equal a3_sum_expected, a3_sum
  end

  def test_block
    a3_block = A.moving_slice(3) { |x, y, z| (x + y) / z.to_f }.to_a
    a3_block_expected = [(1 + 2) / 3.0, (2 + 3) / 4.0, (3 + 4) / 5.0]
    assert_equal a3_block_expected, a3_block
  end
end
