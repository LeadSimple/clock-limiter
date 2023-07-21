# frozen_string_literal: true

require 'test_helper'

class Clock::PeriodTest < Minitest::Test
  def test_error_message_is_human_readable
    error = Clock::Limiter::Period::InvalidError.new(:invalid)

    assert_equal 'Invalid period invalid. Valid periods: [:second, :minute, :hour, :day, :month, :year]', error.message
  end
end
