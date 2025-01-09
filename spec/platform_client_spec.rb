# frozen_string_literal: true

RSpec.describe PlatformClient do
  it 'defines DEFAULT_LANGUAGE' do
    expect(described_class::DEFAULT_LANGUAGE).to eq 'en-US'
  end

  it 'defines SUPPORTED_LANGUAGES' do
    expect(described_class::SUPPORTED_LANGUAGES).to eq %w[en-US ja-JP]
  end

  describe '.configuration' do
    it 'returns a Configuration instance' do
      expect(described_class.configuration).to be_a PlatformClient::Configuration
    end
  end

  describe '.configure' do
    it 'yields a Configuration instance' do
      expect { |b| described_class.configure(&b) }.to yield_with_args(described_class.configuration)
    end
  end
end
