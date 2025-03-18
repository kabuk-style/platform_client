# frozen_string_literal: true

RSpec.describe PlatformClient::Requests::Rate, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:property_code) }
    it { is_expected.to validate_presence_of(:room_code) }

    context 'with format validations' do
      context 'with check_in_date and check_out_date' do
        it { is_expected.to allow_value('2025-01-01').for(:check_in_date) }
        it { is_expected.to allow_value('2025-12-31').for(:check_out_date) }
        it { is_expected.not_to allow_value('01-01-2025').for(:check_in_date) }
        it { is_expected.not_to allow_value('2025/01/01').for(:check_out_date) }
        it { is_expected.not_to allow_value(nil).for(:check_in_date) }
      end

      context 'with adults_count' do
        it { is_expected.to allow_value(rand(1..10)).for(:adults_count) }
        it { is_expected.not_to allow_value(0).for(:adults_count) }
        it { is_expected.not_to allow_value('abc').for(:adults_count) }
      end
    end
  end
end
