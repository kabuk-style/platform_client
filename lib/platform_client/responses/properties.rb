# frozen_string_literal: true

module PlatformClient
  module Responses
    # Represents the response from the Kabuk Platform API for the /api/properties endpoint
    class Properties < Base
      include Contentable
    end
  end
end
