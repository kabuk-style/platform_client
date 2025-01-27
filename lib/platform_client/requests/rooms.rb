# frozen_string_literal: true

module PlatformClient
  module Requests
    # Wrapper for the /api/rooms endpoint
    class Rooms < Base
      include PlatformClient::Requests::Paginated

      attribute :property_codes, array: :string
      attribute :language, :string, default: PlatformClient::DEFAULT_LANGUAGE

      validates :property_codes, presence: true
      validates :language, inclusion: { in: PlatformClient::SUPPORTED_LANGUAGES }, allow_nil: true

      private

      def params
        pagination_params.merge(
          property_codes:,
          language:
        ).compact_blank
      end
    end
  end
end
