# frozen_string_literal: true

module Clock
  module Limiter
    module Period
      SECOND = :second
      MINUTE = :minute
      HOUR = :hour
      DAY = :day
      MONTH = :month
      YEAR = :year

      VALID_PERIODS = [SECOND, MINUTE, HOUR, DAY, MONTH, YEAR].freeze

      class InvalidError < StandardError
        attr_reader :period

        def initialize(period)
          @period = period
          super("Invalid period #{period}. Valid periods: #{VALID_PERIODS}")
        end
      end
    end
  end
end
