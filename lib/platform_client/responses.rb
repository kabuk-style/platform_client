# frozen_string_literal: true

require 'platform_client/responses/base'
require 'platform_client/responses/amenities'
require 'platform_client/responses/chains'
require 'platform_client/responses/facilities'
require 'platform_client/responses/properties'
require 'platform_client/responses/property_categories'
require 'platform_client/responses/room_categories'
require 'platform_client/responses/rooms'
require 'platform_client/responses/rate'
require 'platform_client/responses/booking'

module PlatformClient
  # Wrapper over responses
  # Currently main reason for this is to have consistent method of requiring responses
  module Responses
  end
end
