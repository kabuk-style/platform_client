# frozen_string_literal: true

module PlatformClient
  DEFAULT_LANGUAGE = 'en-US'
  JAPANESE_LANGUAGE = 'ja-JP'
  SUPPORTED_LANGUAGES = [DEFAULT_LANGUAGE, JAPANESE_LANGUAGE].freeze

  module Requests
    # Wrapper for the /api/properties endpoint
    class Properties < Base
      include PlatformClient::Requests::Paginated

      attribute :country_code, :string
      attribute :category_id, array: :string
      attribute :language, :string, default: PlatformClient::DEFAULT_LANGUAGE

      validates :language, inclusion: { in: PlatformClient::SUPPORTED_LANGUAGES }, allow_nil: true
      validates :limit, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 500 }, allow_nil: true
      validates :country_code, format: { with: /\A[A-Z]{2}(,[A-Z]{2})*\z/, message: 'must be a valid ISO 3166-1 alpha-2 country code' }, allow_nil: true

      private

      def params
        pagination_params.merge(
          country_code:,
          category_id:,
          language:
        ).compact
      end
    end
  end
end
