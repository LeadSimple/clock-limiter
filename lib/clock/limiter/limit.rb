# frozen_string_literal: true

module Clock
  module Limiter
    Limit = Struct.new(:period, :limit, keyword_init: true) do
      def initialize(period:, limit:)
        raise Clock::Limiter::Period::InvalidError, period unless Period::VALID_PERIODS.include?(period)

        super
      end
    end
  end
end
