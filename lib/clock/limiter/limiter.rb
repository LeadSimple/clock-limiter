# frozen_string_literal: true

module Clock
  module Limiter
    class NoLimitsError < StandardError
      def initialize
        super('At least one limit must be set')
      end
    end

    # Configure the singleton instance of this class.
    class << self
      # Instantiate the Configuration singleton or return it.
      def configuration
        @configuration ||= Configuration.new
      end

      # This is the configure block definition.
      # The configuration method will return the
      # Configuration singleton, which is then yielded
      # to the configure block.
      def configure
        yield(configuration)
      end

      def included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        attr_reader :clock_limits, :on_clock_limit_failure_block

        # Adds a new value to the `clock_limits` array which will be used to check if
        # the limit has been reached or not.
        #
        # @param [Clock::Limiter::Period] period
        # @param [Integer] limit
        def add_clock_limit(period:, limit:)
          @clock_limits ||= []
          @clock_limits << Limit.new(period: period, limit: limit)
        end

        # Sets the block that will be called when the limit has been reached.
        #
        # @param [Proc] block
        def on_clock_limit_failure(&block)
          @on_clock_limit_failure_block = block
        end
      end
    end

    # Runs the block if the limit has not been reached. If the limit has been
    # reached, the block set with `on_clock_limit_failure` will be called.
    # If no limits have been set, a `NoLimitsError` will be raised.
    # If the limit has been reached, the block set with `on_clock_limit_failure` will
    # be called.
    # If the limit has not been reached, the block passed to this method will
    # be called.
    #
    # @param [String] custom_key Custom key if this limit is not global to the class
    # @yield
    # @return [Object] The return value of the block passed to this method
    # @raise [NoLimitsError] If no limits have been set
    # @raise [Clock::Limiter::Period::InvalidError] If an invalid period has been set
    def with_clock_limiter(custom_key = self.class.name)
      raise NoLimitsError if fail_with_empty_limits?

      self.class.clock_limits&.each do |limit|
        next if within_limit?(limit, custom_key)

        return self.class.on_clock_limit_failure_block&.call(limit, custom_key)
      end

      yield
    end

    private

    def fail_with_empty_limits?
      Clock::Limiter.configuration.fail_with_empty_limits? &&
        (self.class.clock_limits.nil? || self.class.clock_limits.empty?)
    end

    # Increments the value of the key and returns true if the limit has not
    # been reached. If the limit has been reached, false will be returned.
    #
    # @param [Clock::Limiter::Limit] limit
    # @param [String] custom_key
    def within_limit?(limit, custom_key)
      key, ttl = key_and_ttl(limit, custom_key)

      value = Clock::Limiter.configuration.redis.incr(key)
      return false if value > limit.limit

      # If value was first set, then set expiration
      Clock::Limiter.configuration.redis.expire(key, ttl) if value == 1

      true
    end

    # Returns the key and ttl for the given limit and group key.
    #
    # @param [Clock::Limiter::Limit] limit
    # @param [String] custom_key
    def key_and_ttl(limit, custom_key) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      case limit.period
      when Period::SECOND
        [key(limit.period, custom_key), 1]
      when Period::MINUTE
        [key(limit.period, custom_key), 60] # 1 * 60
      when Period::HOUR
        [key(limit.period, custom_key), 3_600] # 1 * 60 * 60
      when Period::DAY
        [key(limit.period, custom_key), 86_400] # 1 * 60 * 60 * 24
      when Period::MONTH
        [key(limit.period, custom_key), 2_678_400] # 1 * 60 * 60 * 24 * 31 (worst case, 31 days)
      when Period::YEAR
        [key(limit.period, custom_key), 31_622_400] # 1 * 60 * 60 * 24 * 366 (worst case, 366 days)
      else
        raise Period::InvalidError(limit.period)
      end
    end

    # Returns the key for the given period and group key.
    #
    # @param [Clock::Limiter::Period] period
    # @param [String] custom_key
    def key(period, custom_key)
      "clock-limiter:#{custom_key}:#{period}:#{current_period(period)}"
    end

    # Returns the current period for the given period.
    # i.e. if the period is Period::SECOND, then we'll return the current second
    # according to the [Clock::Limiter::Configuration#time_provider]
    #
    # @param [Clock::Limiter::Period] period
    def current_period(period) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      case period
      when Period::SECOND
        Clock::Limiter.configuration.time_provider.call.sec
      when Period::MINUTE
        Clock::Limiter.configuration.time_provider.call.min
      when Period::HOUR
        Clock::Limiter.configuration.time_provider.call.hour
      when Period::DAY
        Clock::Limiter.configuration.time_provider.call.day
      when Period::MONTH
        Clock::Limiter.configuration.time_provider.call.month
      when Period::YEAR
        Clock::Limiter.configuration.time_provider.call.year
      else
        raise Period::InvalidError(period)
      end
    end
  end
end
