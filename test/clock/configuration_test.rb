# frozen_string_literal: true

require 'test_helper'

class Clock::ConfigurationTest < Minitest::Test
  def test_raises_error_with_invalid_redis
    config = Clock::Limiter::Configuration.new
    assert_raises(Clock::Limiter::Configuration::ConfigurationError) do
      config.redis = :not_redis
    end
  end

  def test_raises_error_with_invalid_time_provider
    config = Clock::Limiter::Configuration.new
    assert_raises(Clock::Limiter::Configuration::ConfigurationError) do
      config.time_provider = :not_a_proc
    end
  end
end
