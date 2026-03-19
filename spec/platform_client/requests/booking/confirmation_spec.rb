# frozen_string_literal: true

RSpec.describe PlatformClient::Requests::Booking::Confirmation, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:rate_key) }
    it { is_expected.to validate_presence_of(:client_reference) }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:nationality) }
    it { is_expected.to validate_presence_of(:contact_number) }
    it { is_expected.to allow_value('US').for(:nationality) }

    context 'with invalid nationality' do
      it { is_expected.not_to allow_value('US,CA').for(:nationality) }
      it { is_expected.not_to allow_value('us').for(:nationality) }
      it { is_expected.not_to allow_value('USA').for(:nationality) }
    end

    context 'with email' do
      it { is_expected.to allow_value('', nil).for(:email) }
      it { is_expected.to allow_value('user@example.com').for(:email) }
      it { is_expected.not_to allow_value('invalid-email').for(:email) }
    end
  end
end
