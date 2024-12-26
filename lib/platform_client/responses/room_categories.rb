# frozen_string_literal: true

module PlatformClient
  module Responses
    # Represents the response from the Kabuk Platform API for the /api/room_categories endpoint
    class RoomCategories < Base
      include Contentable

      private

      def root_key ='room_categories'
    end
  end
end
