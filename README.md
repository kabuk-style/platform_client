# PlatformClient

This gem is a wrapper for the Kabuk Platform API, designed for internal use.

## Installation

### Using GitHub branch:

```ruby
gem 'platform_client', git: 'https://github.com/kabuk-style/platform_client.git', branch: 'specific-branch'
```

### Using local source:
For development/debugging usage, it's better to use local Gem. Please check this repo and add it to your Gemfile:

```ruby
gem "platform_client", path: "/path/to/platform_client"
```

## Usage:

```ruby
require 'platform_client'

PlatformClient.configure do |c|
  c.base_url = 'https://kabuk-platform.com'
  c.auth_provider = GoogleAuthCredentials.fetch_sa_jwt('https://kabuk-platform.com') # Monorepo
end

chains =  PlatformClient::Requests.chains(page: 2, limit: 100)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kabuk-style/platform_client.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
