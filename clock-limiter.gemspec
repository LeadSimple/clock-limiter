# frozen_string_literal: true

require_relative 'lib/clock/limiter/version'

Gem::Specification.new do |spec| # rubocop:disable Gemspec/RequireMFA because we want to deploy this through the GitHub Actions workflow
  spec.name          = 'clock-limiter'
  spec.version       = Clock::Limiter::VERSION
  spec.authors       = ['Rafael Baldasso Audibert']
  spec.email         = ['engineering+clock-limiter@leadsimple.com']

  spec.summary       = 'Clock-based rate limiter which resets when the clock second/minute/etc. changes.'
  spec.homepage      = 'https://github.com/leadsimple/clock-limiter'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/leadsimple/clock-limiter'
  spec.metadata['changelog_uri'] = 'https://github.com/leadsimple/clock-limiter/blob/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
