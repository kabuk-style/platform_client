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

      context 'with invalid nationality' do
        it { is_expected.to allow_value(('A'..'Z').to_a.sample(2).join).for(:nationality) }
        it { is_expected.not_to allow_value('US,CA,').for(:nationality) }
        it { is_expected.not_to allow_value('us').for(:nationality) }
        it { is_expected.not_to allow_value('USA').for(:nationality) }
      end

      context 'with invalid country code' do
        it { is_expected.to allow_value(('A'..'Z').to_a.sample(2).join).for(:country_code) }
        it { is_expected.not_to allow_value('US,CA,').for(:country_code) }
        it { is_expected.not_to allow_value('us').for(:country_code) }
        it { is_expected.not_to allow_value('USA').for(:country_code) }
      end

      context 'with language' do
        it { is_expected.to allow_value('en-US').for(:language) }
        it { is_expected.to allow_value('ja-JP').for(:language) }
        it { is_expected.to allow_value('ko-KR').for(:language) }
        it { is_expected.to allow_value('zh-TW').for(:language) }
        it { is_expected.to allow_value(nil).for(:language) }
        it { is_expected.not_to allow_value(['', '  ']).for(:language) }
        it { is_expected.not_to allow_value('zh-CN').for(:language) }
        it { is_expected.not_to allow_value(%w[en ja ko zh].sample).for(:language) }
      end
    end
  end
end
