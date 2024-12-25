# frozen_string_literal: true

require 'vcr'
# require 'webmock/rspec' TODO: Uncomment this line

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = true
end
