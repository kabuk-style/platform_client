# frozen_string_literal: true

require_relative 'requests/support_helpers'

RSpec.describe PlatformClient::Requests do
  before { stub_platform_client_configurations! } # comment it to generate new cassette

  def check_pagination(data, expected_current, expected_next)
    pagination = data['pagination']
    expect(pagination).to be_a Hash
    expect(pagination.keys).to contain_exactly('current', 'next')

    expect(pagination['current']).to match(expected_current)
    expect(pagination['next']).to match(expected_next)
  end

  describe '.chains' do
    context 'without specifying any filters', vcr: { cassette_name: 'content/chains_default' } do
      it 'returns a list of chains from first page' do
        response = described_class.chains
        expect(response).to be_a PlatformClient::Responses::Chains

        data = response.data
        expect(data).to be_a Hash
        expect(data.keys).to contain_exactly('chains', 'pagination')

        chains = data['chains']
        expect(chains).to be_a Array
        expect(chains.size).to eq 20
        expect(chains.sample.keys).to contain_exactly('id', 'name')
        expect(chains.first['id']).to eq 1
        expect(chains.first['name']).to eq 'ANA Hotels'
        expect(chains.last['id']).to eq 20
        expect(chains.last['name']).to eq 'Best Western'

        check_pagination(data, { 'page' => 1, 'size' => 20 }, { 'page' => 2, 'size' => 20 })
      end
    end

    context 'with specifying page and limit', vcr: { cassette_name: 'content/chains_page_2_limit_5' } do
      it 'returns a list of chains from second page with 5 items' do
        response = described_class.chains(page: 2, limit: 5)
        expect(response).to be_a PlatformClient::Responses::Chains

        data = response.data
        expect(data).to be_a Hash
        expect(data.keys).to contain_exactly('chains', 'pagination')

        chains = data['chains']
        expect(chains).to be_a Array
        expect(chains.size).to eq 5
        expect(chains.sample.keys).to contain_exactly('id', 'name')
        expect(chains.first['id']).to eq 6
        expect(chains.first['name']).to eq 'AC Hotels'
        expect(chains.last['id']).to eq 10
        expect(chains.last['name']).to eq 'Anasazi Service Corp'

        check_pagination(data, { 'page' => 2, 'size' => 5 }, { 'page' => 3, 'size' => 5 })
      end
    end
  end

  describe '.property_categories' do
    context 'without specifying any filters', vcr: { cassette_name: 'content/property_categories_default' } do
      it 'returns a list of property categories from first page' do
        response = described_class.property_categories
        expect(response).to be_a PlatformClient::Responses::PropertyCategories

        data = response.data
        expect(data).to be_a Hash
        expect(data.keys).to contain_exactly('property_categories', 'pagination')

        property_categories = data['property_categories']
        expect(property_categories).to be_a Array
        expect(property_categories.size).to eq 20
        expect(property_categories.sample.keys).to contain_exactly('id', 'name')
        expect(property_categories.first['id']).to eq 1
        expect(property_categories.first['name']).to eq 'Hotel'
        expect(property_categories.last['id']).to eq 21
        expect(property_categories.last['name']).to eq 'Tree house property'

        check_pagination(data, { 'page' => 1, 'size' => 20 }, { 'page' => 2, 'size' => 20 })
      end
    end

    context 'with specifying page and limit', vcr: { cassette_name: 'content/property_categories_page_2_limit_5' } do
      it 'returns a list of property categories from second page with 5 items' do
        response = described_class.property_categories(page: 2, limit: 5)
        expect(response).to be_a PlatformClient::Responses::PropertyCategories

        data = response.data
        expect(data).to be_a Hash
        expect(data.keys).to contain_exactly('property_categories', 'pagination')

        property_categories = data['property_categories']
        expect(property_categories).to be_a Array
        expect(property_categories.size).to eq 5
        expect(property_categories.sample.keys).to contain_exactly('id', 'name')
        expect(property_categories.first['id']).to eq 6
        expect(property_categories.first['name']).to eq 'Guesthouse'
        expect(property_categories.last['id']).to eq 10
        expect(property_categories.last['name']).to eq 'Chalet'

        check_pagination(data, { 'page' => 2, 'size' => 5 }, { 'page' => 3, 'size' => 5 })
      end
    end
  end

  describe '.room_categories' do
    context 'without specifying any filters', vcr: { cassette_name: 'content/room_categories_default' } do
      it 'returns a list of room categories from first page' do
        response = described_class.room_categories
        expect(response).to be_a PlatformClient::Responses::RoomCategories

        data = response.data
        expect(data).to be_a Hash
        expect(data.keys).to contain_exactly('room_categories', 'pagination')

        room_categories = data['room_categories']
        expect(room_categories).to be_a Array
        expect(room_categories.size).to eq 14
        expect(room_categories.sample.keys).to contain_exactly('id', 'name')
        expect(room_categories.first['id']).to eq 1
        expect(room_categories.first['name']).to eq 'Triple Room'
        expect(room_categories.last['id']).to eq 14
        expect(room_categories.last['name']).to eq 'Japanese Room'

        check_pagination(data, { 'page' => 1, 'size' => 14 }, nil)
      end
    end

    context 'with specifying page and limit', vcr: { cassette_name: 'content/room_categories_page_2_limit_5' } do
      it 'returns a list of room categories from second page with 5 items' do
        response = described_class.room_categories(page: 2, limit: 5)
        expect(response).to be_a PlatformClient::Responses::RoomCategories

        data = response.data
        expect(data).to be_a Hash
        expect(data.keys).to contain_exactly('room_categories', 'pagination')

        room_categories = data['room_categories']
        expect(room_categories).to be_a Array
        expect(room_categories.size).to eq 5
        expect(room_categories.sample.keys).to contain_exactly('id', 'name')
        expect(room_categories.first['id']).to eq 6
        expect(room_categories.first['name']).to eq 'Suite'
        expect(room_categories.last['id']).to eq 10
        expect(room_categories.last['name']).to eq 'MotorHome'

        check_pagination(data, { 'page' => 2, 'size' => 5 }, { 'page' => 3, 'size' => 5 })
      end
    end
  end
end
