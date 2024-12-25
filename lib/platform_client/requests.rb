# frozen_string_literal: true

require 'platform_client/requests/end_point'
require 'platform_client/requests/base'
require 'platform_client/requests/paginated'
require 'platform_client/requests/chains'

module PlatformClient
  # Wrapper over requests
  module Requests
    class << self
      # Get list of chains
      #
      # @param page [Integer] Page number, pass nil to get the first page
      # @param limit [Integer] Number of items per page, pass nil to get the default number of items
      #
      # @return [PlatformClient::Responses::Chains]
      def chains(page: nil, limit: nil)
        Chains.call(page:, limit:)
      end
    end
  end
end
