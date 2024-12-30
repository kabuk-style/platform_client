# frozen_string_literal: true

require_relative 'contentable'

module PlatformClient
  module Responses
    # Represents the response from the Kabuk Platform API for the /api/facilities endpoint
    class Facilities < Base
      include Contentable
    end
  end
end
