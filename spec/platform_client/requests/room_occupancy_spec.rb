# frozen_string_literal: true

require 'webmock/rspec/matchers'
require_relative 'support_helpers'

RSpec.describe PlatformClient::Requests::RoomOccupancy, type: :model do
  include WebMock::API
  include WebMock::Matchers

  before { stub_platform_client_configurations! }
  after { WebMock.reset! }

  let(:uri) { 'https://kabuk-platform.com/api/hafh/properties/EnmG/rooms/201188712.1/occupancy' }
  let(:changed_at) { Time.utc(2026, 10, 5, 14, 0, 0, 123_456) }
  let(:current) do
    {
      'property_code' => 'EnmG',
      'room_code' => '201188712.1',
      'supplier' => 'expedia',
      'adults_counts' => [2],
      'changed_at' => '2026-10-05T14:00:00.123456Z',
    }
  end

  def update_room_occupancy(adults_counts: [1, 2], room_code: '201188712.1', changed_at: self.changed_at)
    PlatformClient::Requests.update_room_occupancy(property_code: 'EnmG', room_code:, adults_counts:, changed_at:)
  end

  def stub_error(status, reason, details: {})
    body = { errors: [{ code: 'HAFH_ROOM_OCCUPANCY_ERROR', message: 'error', reason:, details:, request_id: 'req_1' }] }
    stub_request(:put, uri).to_return(status:, body: body.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:property_code) }
    it { is_expected.to validate_presence_of(:room_code) }
    it { is_expected.to validate_presence_of(:changed_at) }
  end

  describe 'request' do
    before do
      stub_request(:put, %r{/api/hafh/properties/.+/rooms/.+/occupancy})
        .to_return(status: 200, body: { room_occupancy: current }.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'sends an empty adults_counts so the room can be switched off' do
      update_room_occupancy(adults_counts: [])

      expect(a_request(:put, uri).with(body: '{"adults_counts":[],"changed_at":"2026-10-05T14:00:00.123456Z"}')).to have_been_made
    end

    it 'serializes a Time changed_at with microseconds and its offset' do
      update_room_occupancy(changed_at: Time.new(2026, 10, 5, 23, 0, Rational(123_456, 1_000_000), '+09:00'))

      expect(a_request(:put, uri).with(body: { adults_counts: [1, 2], changed_at: '2026-10-05T23:00:00.123456+09:00' })).to have_been_made
    end

    it 'sends a String changed_at as given' do
      update_room_occupancy(changed_at: '2026-10-05T23:00:00+09:00')

      expect(a_request(:put, uri).with(body: { adults_counts: [1, 2], changed_at: '2026-10-05T23:00:00+09:00' })).to have_been_made
    end

    it 'keeps a dot in the room code' do
      update_room_occupancy(room_code: '201188712.1')

      expect(a_request(:put, uri)).to have_been_made
    end

    it 'URL-encodes path segments' do
      update_room_occupancy(room_code: 'a b/c+d')

      expect(a_request(:put, 'https://kabuk-platform.com/api/hafh/properties/EnmG/rooms/a%20b%2Fc%2Bd/occupancy')).to have_been_made
    end

    it 'returns the stored room occupancy' do
      response = update_room_occupancy

      expect(response).to be_a PlatformClient::Responses::RoomOccupancy
      expect(response.room_occupancy).to eq current
      expect(response.property_code).to eq 'EnmG'
      expect(response.room_code).to eq '201188712.1'
      expect(response.supplier).to eq 'expedia'
      expect(response.adults_counts).to eq [2]
      expect(response.changed_at).to eq '2026-10-05T14:00:00.123456Z'
    end
  end

  describe 'errors' do
    it 'raises RoomOccupancyStaleChangeError for a 409 STALE_CHANGE, exposing the stored row' do
      stub_error(409, 'STALE_CHANGE', details: { current: })

      expect { update_room_occupancy }.to raise_error(PlatformClient::Errors::RoomOccupancyStaleChangeError) do |error|
        expect(error.error_reason).to eq 'STALE_CHANGE'
        expect(error.current).to eq current
      end
    end

    it 'raises RoomOccupancyConflictError for a 409 CONFLICTING_CHANGE, exposing the stored row' do
      stub_error(409, 'CONFLICTING_CHANGE', details: { current: })

      expect { update_room_occupancy }.to raise_error(PlatformClient::Errors::RoomOccupancyConflictError) do |error|
        expect(error.error_reason).to eq 'CONFLICTING_CHANGE'
        expect(error.current).to eq current
      end
    end

    %w[UNKNOWN_PROPERTY UNKNOWN_ROOM INVALID_ADULTS_COUNTS INVALID_CHANGED_AT UNLINKABLE_PROPERTY].each do |reason|
      it "raises RoomOccupancyRejectedError, a ValidationError, for a 422 #{reason}" do
        stub_error(422, reason)

        expect { update_room_occupancy }.to raise_error(PlatformClient::Errors::RoomOccupancyRejectedError) do |error|
          expect(error).to be_a PlatformClient::Errors::ValidationError
          expect(error.error_reason).to eq reason
        end
      end
    end

    it 'keeps routing other error codes as before' do
      body = { errors: [{ code: 'NOT_FOUND', message: 'error', reason: 'REASON', details: {}, request_id: 'req_1' }] }
      stub_request(:put, uri).to_return(status: 404, body: body.to_json, headers: { 'Content-Type' => 'application/json' })

      expect { update_room_occupancy }.to raise_error(PlatformClient::Errors::NotFoundError)
    end

    it 'raises InternalError for a 5xx' do
      stub_request(:put, uri).to_return(status: 500, body: { errors: [{ code: 'INTERNAL_ERROR' }] }.to_json, headers: { 'Content-Type' => 'application/json' })

      expect { update_room_occupancy }.to raise_error(PlatformClient::Errors::InternalError)
    end
  end
end
