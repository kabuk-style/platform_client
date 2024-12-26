# frozen_string_literal: true

module PlatformClient
  module Responses
    # Represents the response from the Kabuk Platform API for the /api/property_categories endpoint
    class PropertyCategories < Base
      include Contentable

      private

      def root_key = 'property_categories'
    end
  end
end
