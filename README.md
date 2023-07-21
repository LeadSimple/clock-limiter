# Clock::Limiter

Clock-based rate limiter which resets when the clock second/minute/etc. changes.

This is useful when you are having to deal with a third-party who implemented rate limits which reset when the minute or hour changes instead of having implemented it as a floating 60-second or 60-minute, respectively, window.

## How it works

By setting keys in Redis keeping track of the current second/minute/etc in a carefully crafted key, we can guarantee we are using the current bucket (second, minute, etc.) at any time.

These keys are set to automatically expire in the future. They will stick around for at most the amount of time of the category they belong too, i.e. if it's a minute period, then the key will last for at most one minute in Redis. See [Periods](#periods)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'clock-limiter'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install clock-limiter

## Usage

First, you should configure this in a initializer such as `initializers/clock_limiter.rb`

```ruby
Clock::Limiter.configure do |config|
  config.redis = Redis.new               # Must be a Redis instance
  config.time_provider = -> { Time.now } # Must return a Time instance
end
```

Then, you can include it in a class like so

```ruby
class Limited
  include Clock::Limiter

  add_clock_limit(period: Clock::Limiter::Period::MINUTE, limit: 10)
  add_clock_limit(period: Clock::Limiter::Period::SECOND, limit: 2)

  on_clock_limit_failure do |limit|
    puts "Limit #{limit} reached!"
  end

  def call
    with_clock_limiter do
      puts 'CALLED'
    end
  end
end
```

You can then try it by calling the `#call` instance method repeatedly in less than a second.

```ruby
limited = Limited.new

limited.call # CALLED
limited.call # CALLED
limited.call # Limit Clock::Limiter::Period::SECOND reached!
```

The limit will be global across the `Limited` class.

### Periods

The available periods are

- `Clock::Limiter::Period::SECOND`, where the key lasts for at most 1 second
- `Clock::Limiter::Period::MINUTE`, where the key lasts for at most 1 minute
- `Clock::Limiter::Period::HOUR`, where the key lasts for at most 1 hour
- `Clock::Limiter::Period::DAY`, where the key lasts for at most 24 hours
- `Clock::Limiter::Period::MONTH`, where the key lasts for at most 31 days
- `Clock::Limiter::Period::YEAR`, where the key lasts for at most 366 days

### Advanced Usage

`with_clock_limiter` accepts an optional argument called `group_key` which can be used if you don't want the rate limit to be global across the class, but want it to be based on a specific key instead - if you have different rate limits, for different accounts, this might be your usage.

```ruby
class Limited
  include Clock::Limiter

  add_clock_limit(period: Clock::Limiter::Period::MINUTE, limit: 10)

  on_clock_limit_failure do |limit, group_key|
    puts "Limit #{limit} for key #{group_key} reached!"
  end

  def call
    with_clock_limiter("KEY_1") do
      puts 'CALLED'
    end

    with_clock_limiter("KEY_2") do
      puts 'CALLED 2'
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/clock-limiter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/clock-limiter/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Clock::Limiter project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/clock-limiter/blob/master/CODE_OF_CONDUCT.md).
