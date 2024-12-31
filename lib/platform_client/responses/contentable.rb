# frozen_string_literal: true

module PlatformClient
  module Responses
    # Holds common methods for Content API responses
    module Contentable
      extend ActiveSupport::Concern

      included do
        # Returns data from the response with given root key
        #
        # @return [Array<Hash<String, Object>>]
        def data
          result[root_key]
        end

        # Returns pagination details with current page and next page details
        #
        # @return [Hash<String, Hash<String, Object>>]
        #
        # @example
        #  {
        #     "current" => {
        #       "page" => 1,
        #       "size"=>10
        #     },
        #     "next" => {
        #       "page" => 2,
        #       size"=>10
        #     }
        #  }
        def pagination
          result['pagination']
        end

        private

        # Returns the root key of the response JSON
        #
        # It is derived from the response wrapper class name.
        #
        # For example, if the class name is 'PlatformClient::Responses::Chains',
        # the root key will be 'chains'
        #
        # @example for chains response below, the root key is 'chains'
        #
        # {
        #   "chains": [
        #     {
        #       "id": 1,
        #       "name": "Marriott"
        #     },
        #   ],
        #   "pagination": {
        #     ...
        #   }
        # }
        #
        # Override it if the root key is different
        # @return [String]
        def root_key
          self.class.name.demodulize.underscore
        end
      end
    end
  end
end
