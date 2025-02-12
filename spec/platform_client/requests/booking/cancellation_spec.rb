# frozen_string_literal: true

RSpec.describe PlatformClient::Requests::Booking::Cancellation, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:client_reference) }
  end
end
