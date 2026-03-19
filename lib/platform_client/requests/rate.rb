# frozen_string_literal: true

module PlatformClient
  module Requests
    # Wrapper for the /api/check_rate endpoint
    class Rate < Base
      attribute :property_code, :string
      attribute :room_code, :string
      attribute :check_in_date, :string
      attribute :check_out_date, :string
      attribute :adults_count, :integer
      attribute :nationality, :string
      attribute :country_code, :string
      attribute :language, :string, default: PlatformClient::DEFAULT_LANGUAGE
      attribute :customer_session_id, :string

      validates :property_code, :room_code, presence: true
      validates :check_in_date, :check_out_date, format: { with: /\A\d{4}-\d{2}-\d{2}\z/, message: 'must be in YYYY-MM-DD format' }
      validates :adults_count, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
      validates :nationality, format: { with: /\A[A-Z]{2}\z/, message: 'must be a valid ISO 3166-1 alpha-2 country code' }, allow_blank: true
      validates :country_code, format: { with: /\A[A-Z]{2}\z/, message: 'must be a valid ISO 3166-1 alpha-2 country code' }, allow_blank: true
      validates :language, inclusion: { in: PlatformClient::EXT_SUPPORTED_LANGUAGES }, allow_nil: true
    end
  end
end
