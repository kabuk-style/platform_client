# frozen_string_literal: true

# TODO: Remove this after development
require 'pry'

require 'active_support'
require 'active_support/core_ext'

require 'platform_client/version'
require 'platform_client/constants'
require 'platform_client/errors'
require 'platform_client/configuration'
require 'platform_client/client'
require 'platform_client/requests'
require 'platform_client/responses'

# Kabuk Platform API Wrapper
module PlatformClient
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
