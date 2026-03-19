# frozen_string_literal: true

require 'platform_client/errors'

module PlatformClient
  module Responses
    # Base class for the responses from Kabuk Platform API
    class Base
      include ActiveModel::Model
      include ActiveModel::Attributes

      attr_reader :result, :original_response
      alias data result

      # @param response [Faraday::Response] the response from the Kabuk Platform API
      def initialize(response)
        @original_response = response
        @result = response.body
      end

      # Returns customer session ID from the response headers
      # @return [String, nil] the customer session ID or nil if not present
      def customer_session_id
        @original_response.headers['x-customer-session-id'] || @original_response.headers['X-Customer-Session-Id']
      end
    end
  end
end
