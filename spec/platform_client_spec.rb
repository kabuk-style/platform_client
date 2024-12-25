# frozen_string_literal: true

RSpec.describe PlatformClient do
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
