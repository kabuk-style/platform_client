# frozen_string_literal: true

module PlatformClient
  module Requests
    class Amenities < Base
      include PlatformClient::Requests::Paginated
    end
  end
end
