# frozen_string_literal: true

require 'erb'

module PlatformClient
  module Requests
    # Wrapper for the put /api/hafh/properties/:property_code/rooms/:room_code/occupancy endpoint
    class RoomOccupancy < Base
      ERROR_CODE = 'HAFH_ROOM_OCCUPANCY_ERROR'

      # All outcomes share ERROR_CODE, so they are routed by reason. Any other reason is a 422 rejection.
      ERROR_REASON_MAP = {
        'STALE_CHANGE' => PlatformClient::Errors::RoomOccupancyStaleChangeError,
        'CONFLICTING_CHANGE' => PlatformClient::Errors::RoomOccupancyConflictError,
      }.freeze

      attribute :property_code, :string
      attribute :room_code, :string
      attribute :adults_counts
      # Untyped so a String is sent as given and a Time keeps its sub-second precision (see #serialized_changed_at)
      attribute :changed_at

      validates :property_code, :room_code, :changed_at, presence: true

      private

      def uri_params
        { property_code: ERB::Util.url_encode(property_code.to_s), room_code: ERB::Util.url_encode(room_code.to_s) }
      end

      # Sent as given, without compact_blank: an empty adults_counts switches the room off.
      def params
        { adults_counts:, changed_at: serialized_changed_at }
      end

      # Platform stores changed_at at microsecond precision, so a Time is serialized with microseconds to
      # avoid two changes within the same second colliding as CONFLICTING_CHANGE.
      def serialized_changed_at
        changed_at.respond_to?(:iso8601) ? changed_at.iso8601(6) : changed_at
      end

      def build_error(faraday_error)
        error = super
        return error if error.is_a?(PlatformClient::Errors::InternalError) || error.error_code != ERROR_CODE

        klass = ERROR_REASON_MAP.fetch(error.error_reason, PlatformClient::Errors::RoomOccupancyRejectedError)
        klass.new(error.original_error)
      end
    end
  end
end
