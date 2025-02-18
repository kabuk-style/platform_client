# frozen_string_literal: true

require_relative 'lib/platform_client/version'

Gem::Specification.new do |spec|
  spec.name = 'platform_client'
  spec.version = PlatformClient::VERSION
  spec.authors = ['Kabuk Style Inc.', 'Platform Unit']
  spec.email = ['info@kabuk.com']

  spec.summary = 'Ruby client for Kabuk Platform API'
  spec.description = spec.summary
  spec.homepage = 'https://github.com/kabuk-style/platform_client'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.3.5'

  spec.metadata['allowed_push_host'] = 'https://rubygems.pkg.github.com/kabuk-style'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.com/kabuk-style/platform_client/blob/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github .gitignore .rubocop.yml .rspec appveyor Gemfile Rakefile README.md CHANGELOG.md])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Dependencies
  ## Main dependencies
  spec.add_dependency 'activemodel', '>= 7.2', '< 9'
  spec.add_dependency 'activesupport', '>= 7.2', '< 9'
  spec.add_dependency 'faraday', '~> 1.10'
  spec.add_dependency 'faraday-gzip', '~> 2.0'

  # TODO: Remove this dependency after development. This is here
  # to allow us to use `binding.pry` in the gem.
  spec.add_dependency 'pry'

  ## Development dependencies
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'rspec-github', '~> 2.4.0'
  spec.add_development_dependency 'rubocop', '~> 1.69'
  spec.add_development_dependency 'rubocop-performance', '~> 1.23'
  spec.add_development_dependency 'rubocop-rspec', '~> 3.3'
  spec.add_development_dependency 'shoulda-matchers', '~> 6.0'
  spec.add_development_dependency 'vcr', '~> 6.3'
  spec.add_development_dependency 'webmock', '~> 3.24'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
