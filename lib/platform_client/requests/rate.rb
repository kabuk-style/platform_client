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

      validates :property_code, :room_code, presence: true
      validates :check_in_date, :check_out_date, format: { with: /\A\d{4}-\d{2}-\d{2}\z/, message: 'must be in YYYY-MM-DD format' }
      validates :adults_count, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 5 }, allow_nil: true
    end
  end
end
