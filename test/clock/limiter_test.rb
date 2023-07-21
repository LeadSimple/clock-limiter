# frozen_string_literal: true

require 'test_helper'

# rubocop:disable Lint/EmptyBlock
class Clock::LimiterTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Clock::Limiter::VERSION
  end

  def test_properly_saves_clock_limits
    my_class = Class.new do
      include Clock::Limiter

      add_clock_limit(period: Clock::Limiter::Period::MINUTE, limit: 2)
    end

    assert_equal 1, my_class.clock_limits.length

    assert_equal Clock::Limiter::Period::MINUTE, my_class.clock_limits.first.period
    assert_equal 2, my_class.clock_limits.first.limit
  end

  def test_saves_on_clock_limit_failure_block
    my_class = Class.new do
      include Clock::Limiter

      on_clock_limit_failure do
        puts 'Example'
      end
    end

    assert my_class.on_clock_limit_failure_block
    assert my_class.on_clock_limit_failure_block.is_a?(Proc)
  end

  def test_properly_configures_gem
    configure_gem

    assert Clock::Limiter.configuration.redis
    assert Clock::Limiter.configuration.time_provider
  end

  def test_good_path # rubocop:disable Metrics/MethodLength
    configure_gem

    failed_count = 0
    my_class = Class.new do
      include Clock::Limiter

      add_clock_limit(period: Clock::Limiter::Period::MINUTE, limit: 4)

      on_clock_limit_failure do
        failed_count += 1
      end

      def call
        with_clock_limiter {}
      end
    end

    instance = my_class.new
    6.times { instance.call }

    assert_equal 2, failed_count
  end

  def test_with_clock_limiter_with_group_key # rubocop:disable Metrics/MethodLength
    configure_gem

    failed_groups = []
    my_class = Class.new do
      include Clock::Limiter

      add_clock_limit(period: Clock::Limiter::Period::MINUTE, limit: 1)

      on_clock_limit_failure do |_limit, key_group|
        failed_groups << key_group
      end

      def call
        with_clock_limiter('key_a') {}
        with_clock_limiter('key_b') {}
        with_clock_limiter('key_b') {}
      end
    end

    instance = my_class.new
    instance.call

    assert_equal ['key_b'], failed_groups
  end

  private

  def configure_gem
    Clock::Limiter.configure do |config|
      config.redis = Redis.new
      config.time_provider = -> { Time.now }
    end
  end
end
# rubocop:enable Lint/EmptyBlock
