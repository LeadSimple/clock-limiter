# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'clock/limiter'

require 'minitest/autorun'
require 'fakeredis/minitest'
