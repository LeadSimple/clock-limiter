# frozen_string_literal: true

require 'redis'

module Clock
  module Limiter
    class Configuration
      class ConfigurationError < StandardError; end

      # @param redis [::Redis]
      def redis=(redis)
        raise ConfigurationError, '`redis` must be a `::Redis` instance' unless redis.is_a?(::Redis)

        @redis = redis
      end

      # @return [::Redis]
      def redis
        raise ConfigurationError, 'Redis not configured' if @redis.nil?

        @redis
      end

      # @param time_provider [Proc]
      def time_provider=(time_provider)
        raise ConfigurationError, '`time_provider` must be a Proc' unless time_provider.is_a?(Proc)

        @time_provider = time_provider
      end

      # @return [Proc]
      def time_provider
        raise ConfigurationError, 'Time provider not configured' if @time_provider.nil?

        @time_provider
      end

      # @param fail_with_empty_limits [Boolean]
      def fail_with_empty_limits=(fail_with_empty_limits)
        unless [true, false].include?(fail_with_empty_limits)
          raise ConfigurationError, '`fail_with_empty_limits` must be a boolean'
        end

        @fail_with_empty_limits = fail_with_empty_limits
      end

      # @return [Boolean] - true by default
      def fail_with_empty_limits?
        return @fail_with_empty_limits unless @fail_with_empty_limits.nil?

        true
      end
    end
  end
end
