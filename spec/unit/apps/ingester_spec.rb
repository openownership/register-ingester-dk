require 'json'
require 'register_ingester_dk/apps/ingester'

RSpec.describe RegisterIngesterDk::Apps::Ingester do
  subject { described_class.new(records_handler: records_handler, dk_client: dk_client) }

  let(:records_handler) { double 'records_handler'}
  let(:dk_client) { double 'dk_client'}

  let(:records) do
    [JSON.parse(File.read('./spec/fixtures/dk_record.json'))]
  end

  before do
    expect(dk_client).to receive(:all_records).and_return(
      records
    )
  end

  describe '#call' do
    context 'when records are empty' do
      let(:records) { [] }

      it 'does not call record handler' do
        expect(records_handler).not_to receive(:handle_records)

        subject.call
      end
    end

    context 'when records are not empty' do
      it 'does not call record handler' do
        allow(records_handler).to receive(:handle_records)

        subject.call

        expect(records_handler).to have_received(:handle_records)
      end
    end

    context 'when records are not valid' do
      let(:records) { ['abc'] }

      it 'raises an error' do
        allow(records_handler).to receive(:handle_records)

        expect { subject.call }.to raise_error Dry::Struct::Error
      end
    end
  end
end
