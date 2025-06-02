# frozen_string_literal: true

module PlatformClient
  module Requests
    # Wrapper for the /api/properties endpoint
    class Properties < Base
      include PlatformClient::Requests::Paginated

      attribute :country_code, :string
      attribute :category_ids, array: :string
      attribute :codes, array: :string
      attribute :languages, array: :string, default: [PlatformClient::DEFAULT_LANGUAGE]

      validates :limit, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 500 }, allow_nil: true
      validates :country_code, format: { with: /\A[A-Z]{2}(,[A-Z]{2})*\z/, message: 'must be a valid ISO 3166-1 alpha-2 country code' }, allow_nil: true

      private

      def params
        pagination_params.merge(
          country_code:,
          category_ids:,
          codes:,
          languages:
        ).compact_blank
      end
    end
  end
end
