# frozen_string_literal: true

require 'register_ingester_dk/clients/dk_client'

RSpec.describe RegisterIngesterDk::Clients::DkClient do
  let(:elasticsearch_client) { double 'es_client' }

  before do
    allow(Elasticsearch::Client).to receive(:new).and_return(elasticsearch_client)
  end

  describe '#all_records' do
    subject { described_class.new('u', 'p').all_records }

    let :first_results do
      {
        '_scroll_id' => 's123',
        'hits' => {
          'hits' => [
            { '_source' => { 'Vrdeltagerperson' => {} } },
            { '_source' => { 'Vrdeltagerperson' => {} } }
          ]
        }
      }
    end

    let :second_results do
      {
        '_scroll_id' => 's124',
        'hits' => {
          'hits' => [{ '_source' => { 'Vrdeltagerperson' => {} } }]
        }
      }
    end

    let :empty_results do
      {
        'hits' => {
          'hits' => []
        }
      }
    end

    before do
      allow(elasticsearch_client).to receive(:search)
        .with(hash_including(scroll: '10m'))
        .and_return(first_results)

      allow(elasticsearch_client).to receive(:scroll)
        .with(body: { scroll_id: 's123' }, scroll: '10m')
        .and_return(second_results)

      allow(elasticsearch_client).to receive(:scroll)
        .with(body: { scroll_id: 's124' }, scroll: '10m')
        .and_return(empty_results)
    end

    it 'returns an enumerator' do
      expect(subject).to be_an(Enumerator)
    end

    it 'fetches data using the scroll API, yields each record, then fetches the next set of results' do
      results = subject.to_a
      expect(results.length).to be 3
      expect(results).to all be_a(Hash)
    end
  end
end
