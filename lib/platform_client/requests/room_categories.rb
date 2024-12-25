# frozen_string_literal: true

module PlatformClient
  module Requests
    class RoomCategories < Base
      include PlatformClient::Requests::Paginated
    end
  end
end
