# frozen_string_literal: true

RSpec.describe PlatformClient::Requests::EndPoint do
  describe '.find!' do
    it 'returns the correct endpoint for amenities' do
      endpoint = described_class.find!(:amenities)

      expect(endpoint.uri).to eq('/api/amenities')
      expect(endpoint.method).to eq(:get)
      expect(endpoint.type).to eq(:content)
    end

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

    it 'returns the correct endpoint for properties' do
      endpoint = described_class.find!(:properties)

      expect(endpoint.uri).to eq('/api/properties')
      expect(endpoint.method).to eq(:get)
      expect(endpoint.type).to eq(:content)
    end

    it 'returns the correct endpoint for property_categories' do
      endpoint = described_class.find!(:property_categories)

      expect(endpoint.uri).to eq('/api/property_categories')
      expect(endpoint.method).to eq(:get)
      expect(endpoint.type).to eq(:content)
    end

    it 'returns the correct endpoint for room_categories' do
      endpoint = described_class.find!(:room_categories)

      expect(endpoint.uri).to eq('/api/room_categories')
      expect(endpoint.method).to eq(:get)
      expect(endpoint.type).to eq(:content)
    end

    it 'returns the correct endpoint for rate' do
      endpoint = described_class.find!(:rate)

      expect(endpoint.uri).to eq('/api/check_rate')
      expect(endpoint.method).to eq(:get)
      expect(endpoint.type).to eq(:shopping)
    end

    it 'returns the correct endpoint for booking' do
      endpoint = described_class.find!(:booking)

      expect(endpoint.uri).to eq('/api/bookings')
      expect(endpoint.method).to eq(:post)
      expect(endpoint.type).to eq(:shopping)
    end
  end
end
