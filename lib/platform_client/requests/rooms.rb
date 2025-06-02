# frozen_string_literal: true

module PlatformClient
  module Requests
    # Wrapper for the /api/rooms endpoint
    class Rooms < Base
      include PlatformClient::Requests::Paginated

      attribute :property_codes, array: :string
      attribute :room_codes, array: :string
      attribute :languages, array: :string, default: [PlatformClient::DEFAULT_LANGUAGE]

      validates :property_codes, presence: true

      private

      def params
        pagination_params.merge(
          property_codes:,
          room_codes:,
          languages:
        ).compact_blank
      end
    end
  end
end
