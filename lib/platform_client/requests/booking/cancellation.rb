# frozen_string_literal: true

module PlatformClient
  module Requests
    module Booking
      # Wrapper for the delete /api/bookings/:client_reference endpoint
      class Cancellation < Base
        attribute :client_reference, :string
        attribute :guest_ip, :string

        validates :client_reference, presence: true

        private

        def uri_params
          { client_reference: }
        end

        def params
          { guest_ip: }
        end
      end
    end
  end
end
