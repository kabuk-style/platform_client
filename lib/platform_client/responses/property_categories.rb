# frozen_string_literal: true

module PlatformClient
  module Responses
    # Represents the response from the Kabuk Platform API for the /api/property_categories endpoint
    class PropertyCategories < Base
      include Contentable
    end
  end
end
