# frozen_string_literal: true

require 'vcr'
# require 'webmock/rspec' TODO: Uncomment this line

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = true

  # Replace sensitive data with placeholders
  config.filter_sensitive_data('<ACCESS_TOKEN>') { |interaction| interaction.response.body.match(/"access_token":\s?"([^"]+)"/)&.[](1) }
  config.filter_sensitive_data('<ID_TOKEN>') { |interaction| interaction.response.body.match(/"id_token":\s?"([^"]+)"/)&.[](1) }
  config.filter_sensitive_data('<BEARER_TOKEN>') { |interaction| interaction.request.headers['Authorization']&.first&.gsub('Bearer ', '') }
  config.filter_sensitive_data('<GCP_OAUTH_TOKEN_REFRESH>') do |interaction|
    interaction.request.body.gsub!(/grant_type=refresh_token&refresh_token=[^&]+&client_id=[^&]+&client_secret=[^&]+/, 'GCP_OAUTH_TOKEN_REFRESH')
  end
  config.filter_sensitive_data('<GAESA_COOKIE>') do |interaction|
    interaction.response.headers['Set-Cookie']&.first&.gsub!(/GAESA=[^;]+/, 'GAESA=<GAESA_COOKIE>')
  end
end
