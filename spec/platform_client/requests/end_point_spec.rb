# frozen_string_literal: true

RSpec.describe PlatformClient::Requests::EndPoint do
  describe '.find!' do
    it 'returns the correct endpoint for chains' do
      endpoint = described_class.find!(:chains)

      expect(endpoint.uri).to eq('/api/chains')
      expect(endpoint.method).to eq(:get)
      expect(endpoint.type).to eq(:content)
    end

    it 'returns the correct endpoint for facilities' do
      endpoint = described_class.find!(:facilities)

      expect(endpoint.uri).to eq('/api/facilities')
      expect(endpoint.method).to eq(:get)
      expect(endpoint.type).to eq(:content)
    end
  end
end
