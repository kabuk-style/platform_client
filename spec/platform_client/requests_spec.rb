# frozen_string_literal: true

require_relative 'requests/support_helpers'

RSpec.describe PlatformClient::Requests do
  before { stub_platform_client_configurations! } # comment it to generate new cassette

  def check_pagination(pagination, expected_current, expected_next)
    expect(pagination).to be_a Hash
    expect(pagination.keys).to contain_exactly('current', 'next')

    expect(pagination['current']).to match(expected_current)
    expect(pagination['next']).to match(expected_next)
  end

  describe '.amenities' do
    context 'without specifying any filters', vcr: { cassette_name: 'content/amenities_default' } do
      it 'returns a list of amenities from first page' do
        response = described_class.amenities
        expect(response).to be_a PlatformClient::Responses::Amenities

        amenities = response.data
        expect(amenities).to be_a Array
        expect(amenities.size).to eq 12
        expect(amenities.sample.keys).to contain_exactly('id', 'name')
        expect(amenities.first['id']).to eq 1
        expect(amenities.first['name']).to eq 'LCD TV'
        expect(amenities.last['id']).to eq 12
        expect(amenities.last['name']).to eq 'Umbrella'

        check_pagination(response.pagination, { 'page' => 1, 'size' => 12 }, nil)
      end
    end

    context 'with specifying page and limit', vcr: { cassette_name: 'content/amenities_page_2_limit_5' } do
      it 'returns a list of amenities from second page with 5 items' do
        response = described_class.amenities(page: 2, limit: 5)
        expect(response).to be_a PlatformClient::Responses::Amenities

        amenities = response.data
        expect(amenities).to be_a Array
        expect(amenities.size).to eq 5
        expect(amenities.sample.keys).to contain_exactly('id', 'name')
        expect(amenities.first['id']).to eq 6
        expect(amenities.first['name']).to eq 'diving'
        expect(amenities.last['id']).to eq 10
        expect(amenities.last['name']).to eq 'Aquatic Sports'

        check_pagination(response.pagination, { 'page' => 2, 'size' => 5 }, { 'page' => 3, 'size' => 5 })
      end
    end
  end

  describe '.chains' do
    context 'without specifying any filters', vcr: { cassette_name: 'content/chains_default' } do
      it 'returns a list of chains from first page' do
        response = described_class.chains
        expect(response).to be_a PlatformClient::Responses::Chains

        chains = response.data
        expect(chains).to be_a Array
        expect(chains.size).to eq 20
        expect(chains.sample.keys).to contain_exactly('id', 'name')
        expect(chains.first['id']).to eq 1
        expect(chains.first['name']).to eq 'ANA Hotels'
        expect(chains.last['id']).to eq 20
        expect(chains.last['name']).to eq 'Best Western'

        check_pagination(response.pagination, { 'page' => 1, 'size' => 20 }, { 'page' => 2, 'size' => 20 })
      end
    end

    context 'with specifying page and limit', vcr: { cassette_name: 'content/chains_page_2_limit_5' } do
      it 'returns a list of chains from second page with 5 items' do
        response = described_class.chains(page: 2, limit: 5)
        expect(response).to be_a PlatformClient::Responses::Chains

        chains = response.data
        expect(chains).to be_a Array
        expect(chains.size).to eq 5
        expect(chains.sample.keys).to contain_exactly('id', 'name')
        expect(chains.first['id']).to eq 6
        expect(chains.first['name']).to eq 'AC Hotels'
        expect(chains.last['id']).to eq 10
        expect(chains.last['name']).to eq 'Anasazi Service Corp'

        check_pagination(response.pagination, { 'page' => 2, 'size' => 5 }, { 'page' => 3, 'size' => 5 })
      end
    end
  end

  describe '.facilities' do
    context 'without specifying any filters', vcr: { cassette_name: 'content/facilities_default' } do
      it 'returns a list of facilities from first page' do
        response = described_class.facilities
        expect(response).to be_a PlatformClient::Responses::Facilities

        facilities = response.data
        expect(facilities).to be_a Array
        expect(facilities.size).to eq 12
        expect(facilities.sample.keys).to contain_exactly('id', 'name')
        expect(facilities.first['id']).to eq 1
        expect(facilities.first['name']).to eq 'Simulated golf course'
        expect(facilities.last['id']).to eq 12
        expect(facilities.last['name']).to eq 'Outdoor swimming pool'

        check_pagination(response.pagination, { 'page' => 1, 'size' => 12 }, nil)
      end
    end

    context 'with specifying page and limit', vcr: { cassette_name: 'content/facilities_page_2_limit_5' } do
      it 'returns a list of facilities from second page with 5 items' do
        response = described_class.facilities(page: 2, limit: 5)
        expect(response).to be_a PlatformClient::Responses::Facilities

        facilities = response.data
        expect(facilities).to be_a Array
        expect(facilities.size).to eq 5
        expect(facilities.sample.keys).to contain_exactly('id', 'name')
        expect(facilities.first['id']).to eq 6
        expect(facilities.first['name']).to eq 'Gymnasium'
        expect(facilities.last['id']).to eq 10
        expect(facilities.last['name']).to eq 'Call car service'

        check_pagination(response.pagination, { 'page' => 2, 'size' => 5 }, { 'page' => 3, 'size' => 5 })
      end
    end
  end

  describe '.property_categories' do
    context 'without specifying any filters', vcr: { cassette_name: 'content/property_categories_default' } do
      it 'returns a list of property categories from first page' do
        response = described_class.property_categories
        expect(response).to be_a PlatformClient::Responses::PropertyCategories

        property_categories = response.data
        expect(property_categories).to be_a Array
        expect(property_categories.size).to eq 20
        expect(property_categories.sample.keys).to contain_exactly('id', 'name')
        expect(property_categories.first['id']).to eq 1
        expect(property_categories.first['name']).to eq 'Hotel'
        expect(property_categories.last['id']).to eq 21
        expect(property_categories.last['name']).to eq 'Tree house property'

        check_pagination(response.pagination, { 'page' => 1, 'size' => 20 }, { 'page' => 2, 'size' => 20 })
      end
    end

    context 'with specifying page and limit', vcr: { cassette_name: 'content/property_categories_page_2_limit_5' } do
      it 'returns a list of property categories from second page with 5 items' do
        response = described_class.property_categories(page: 2, limit: 5)
        expect(response).to be_a PlatformClient::Responses::PropertyCategories

        property_categories = response.data
        expect(property_categories).to be_a Array
        expect(property_categories.size).to eq 5
        expect(property_categories.sample.keys).to contain_exactly('id', 'name')
        expect(property_categories.first['id']).to eq 6
        expect(property_categories.first['name']).to eq 'Guesthouse'
        expect(property_categories.last['id']).to eq 10
        expect(property_categories.last['name']).to eq 'Chalet'

        check_pagination(response.pagination, { 'page' => 2, 'size' => 5 }, { 'page' => 3, 'size' => 5 })
      end
    end
  end

  describe '.room_categories' do
    context 'without specifying any filters', vcr: { cassette_name: 'content/room_categories_default' } do
      it 'returns a list of room categories from first page' do
        response = described_class.room_categories
        expect(response).to be_a PlatformClient::Responses::RoomCategories

        room_categories = response.data
        expect(room_categories).to be_a Array
        expect(room_categories.size).to eq 14
        expect(room_categories.sample.keys).to contain_exactly('id', 'name')
        expect(room_categories.first['id']).to eq 1
        expect(room_categories.first['name']).to eq 'Triple Room'
        expect(room_categories.last['id']).to eq 14
        expect(room_categories.last['name']).to eq 'Japanese Room'

        check_pagination(response.pagination, { 'page' => 1, 'size' => 14 }, nil)
      end
    end

    context 'with specifying page and limit', vcr: { cassette_name: 'content/room_categories_page_2_limit_5' } do
      it 'returns a list of room categories from second page with 5 items' do
        response = described_class.room_categories(page: 2, limit: 5)
        expect(response).to be_a PlatformClient::Responses::RoomCategories

        room_categories = response.data
        expect(room_categories).to be_a Array
        expect(room_categories.size).to eq 5
        expect(room_categories.sample.keys).to contain_exactly('id', 'name')
        expect(room_categories.first['id']).to eq 6
        expect(room_categories.first['name']).to eq 'Suite'
        expect(room_categories.last['id']).to eq 10
        expect(room_categories.last['name']).to eq 'MotorHome'

        check_pagination(response.pagination, { 'page' => 2, 'size' => 5 }, { 'page' => 3, 'size' => 5 })
      end
    end
  end
end
