# frozen_string_literal: true

require 'platform_client/errors'

module PlatformClient
  module Responses
    # Base class for the responses from PlatformClient Platform API
    class Base
      include ActiveModel::Model
      include ActiveModel::Attributes

      attr_reader :result, :original_response
      alias data result

      # @param response [Faraday::Response] the response from the PlatformClient Platform API
      def initialize(response)
        @original_response = response
        @result = response.body
      end
    end
  end
end
