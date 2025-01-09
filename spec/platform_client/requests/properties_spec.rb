# frozen_string_literal: true

RSpec.describe PlatformClient::Requests::Properties, type: :model do
  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:language).in_array(PlatformClient::SUPPORTED_LANGUAGES).allow_nil }
    it { is_expected.to allow_value('US').for(:country_code) }

    context 'with invalid country code' do
      it { is_expected.to allow_value('US,CA').for(:country_code) }
      it { is_expected.not_to allow_value('US,CA,').for(:country_code) }
      it { is_expected.not_to allow_value('us').for(:country_code) }
      it { is_expected.not_to allow_value('USA').for(:country_code) }
    end

    context 'with pagination params' do
      context 'with page' do
        it { is_expected.to allow_value('').for(:page) }
        it { is_expected.to allow_value(rand(1..1000)).for(:page) }
        it { is_expected.not_to allow_value(0).for(:page) }
        it { is_expected.not_to allow_value('abc').for(:page) }
      end

      context 'with limit' do
        it { is_expected.to allow_value('').for(:limit) }
        it { is_expected.to allow_value(1).for(:limit) }
        it { is_expected.to allow_value(500).for(:limit) }
        it { is_expected.not_to allow_value(0).for(:limit) }
        it { is_expected.not_to allow_value(rand(501..1000)).for(:limit) }
        it { is_expected.not_to allow_value('abc').for(:limit) }
      end
    end
  end
end
