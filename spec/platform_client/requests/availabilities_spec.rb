# frozen_string_literal: true

RSpec.describe PlatformClient::Requests::Availabilities, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:property_code) }

    context 'with format validations' do
      context 'with check_in_date and check_out_date' do
        it { is_expected.to allow_value('2025-01-01').for(:from_date) }
        it { is_expected.to allow_value('2025-12-31').for(:to_date) }
        it { is_expected.not_to allow_value('01-01-2025').for(:from_date) }
        it { is_expected.not_to allow_value('2025/01/01').for(:to_date) }
        it { is_expected.not_to allow_value(nil).for(:from_date) }
        it { is_expected.not_to allow_value(nil).for(:to_date) }
      end

      context 'with adults_count' do
        it { is_expected.to allow_value(rand(1..10)).for(:adults_count) }
        it { is_expected.not_to allow_value(0).for(:adults_count) }
        it { is_expected.not_to allow_value('abc').for(:adults_count) }
      end
    end
  end

  describe 'request params' do
    it 'includes board_code when set' do
      request = described_class.new(property_code: 'bk60', board_code: 'breakfast')
      expect(request.send(:params)).to include('board_code' => 'breakfast')
    end

    it 'omits board_code when not set' do
      request = described_class.new(property_code: 'bk60')
      expect(request.send(:params)).not_to have_key('board_code')
    end
  end
end
