# frozen_string_literal: true

require 'test_helper'

class Clock::LimitTest < Minitest::Test
  def test_raises_error_with_invalid_period
    assert_raises(Clock::Limiter::Period::InvalidError) do
      Clock::Limiter::Limit.new(period: :invalid, limit: 2)
    end
  end
end
