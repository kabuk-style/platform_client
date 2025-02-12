# frozen_string_literal: true

module PlatformClient
  module Requests
    module Booking
      # Wrapper for the delete /api/bookings/:client_reference endpoint
      class Cancellation < Base
        attribute :client_reference, :string

        validates :client_reference, presence: true

        private

        def uri_params
          attributes
        end

        def params
          {}
        end
      end
    end
  end
end
