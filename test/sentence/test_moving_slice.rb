#!/usr/bin/env ruby

require 'test/unit'
require 'sentence'

class TestMovingSlice < Test::Unit::TestCase
  using Sentence

  A = [1, 2, 3, 4, 5].freeze

  def test_to_a
    result = A.moving_slice(3).to_a
    expected = [[1, 2, 3], [2, 3, 4], [3, 4, 5]]
    assert_equal expected, result
  end

  def test_method
    result = A.moving_slice(3, &:sum).to_a
    expected = [(1 + 2 + 3), (2 + 3 + 4), (3 + 4 + 5)]
    assert_equal expected, result
  end

  def test_block
    result = A.moving_slice(3) { |x, y, z| (x + y) / z.to_f }.to_a
    expected = [(1 + 2) / 3.0, (2 + 3) / 4.0, (3 + 4) / 5.0]
    assert_equal expected, result
  end

  def test_overrun_to_a
    result = A.moving_slice(A.count + 1).to_a
    expected = [A]
    assert_equal expected, result
  end

  def test_overrun_method
    result = A.moving_slice(A.count + 1, &:sum).to_a
    expected = [A.sum]
    assert_equal expected, result
  end
end
