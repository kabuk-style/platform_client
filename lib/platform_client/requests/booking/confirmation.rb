# frozen_string_literal: true

module PlatformClient
  module Requests
    module Booking
      # Wrapper for the post /api/bookings endpoint
      class Confirmation < Base
        attribute :rate_key, :string
        attribute :client_reference, :string
        attribute :first_name, :string
        attribute :last_name, :string
        attribute :nationality, :string
        attribute :contact_number, :string
        attribute :email, :string
        attribute :guest_ip, :string

        validates :client_reference, :first_name, :last_name, :nationality, :rate_key, :contact_number, presence: true
        validates :nationality, format: { with: /\A[A-Z]{2}\z/, message: 'must be a valid ISO 3166-1 alpha-2 country code' }
        validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
      end
    end
  end
end
