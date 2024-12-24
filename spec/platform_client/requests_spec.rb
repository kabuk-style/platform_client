# frozen_string_literal: true

require_relative 'requests/support_helpers'

RSpec.describe PlatformClient::Requests do
  before { stub_platform_client_configurations! } # comment it to generate new cassette

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

        pagination = data['pagination']
        expect(pagination).to be_a Hash
        expect(pagination.keys).to contain_exactly('current', 'next')

        expect(pagination['current']).to match('page' => 1, 'size' => 20)
        expect(pagination['next']).to match('page' => 2, 'size' => 20)
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

        pagination = data['pagination']
        expect(pagination).to be_a Hash
        expect(pagination.keys).to contain_exactly('current', 'next')

        expect(pagination['current']).to match('page' => 2, 'size' => 5)
        expect(pagination['next']).to match('page' => 3, 'size' => 5)
      end
    end
  end
end
