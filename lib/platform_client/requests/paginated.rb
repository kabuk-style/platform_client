# frozen_string_literal: true

module PlatformClient
  module Requests
    # Adds pagination params to the request
    module Paginated
      extend ActiveSupport::Concern

      included do
        attribute :page, :integer
        attribute :limit, :integer

        validates :page, :limit, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

        private

        def params
          {
            page:,
            limit:,
          }.compact_blank
        end
        alias_method :pagination_params, :params
      end
    end
  end
end
