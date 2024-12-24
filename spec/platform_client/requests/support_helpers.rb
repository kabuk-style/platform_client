# frozen_string_literal: true

class DummyAuthTokenStorage
  def self.get_auth_token # rubocop:disable Naming/AccessorMethodName
    'fake_token'
  end
end

def stub_platform_client_configurations!
  # NOTE: To generate new cassette
  # 1. Comment below code
  # 2. Run the example to generate new cassette
  # 3. Uncomment below code
  # 4. Replace following stubbed value at relevant places in cassette and rerun specs!

  # Dummy configuration
  PlatformClient.configure do |c|
    c.base_url = 'https://kabuk-platform.com'
    c.auth_provider = DummyAuthTokenStorage
  end
end
