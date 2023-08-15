require 'json'
require 'register_ingester_dk/records_handler'

RSpec.describe RegisterIngesterDk::RecordsHandler do
  subject { described_class.new(repository:, producer:) }

  let(:repository) { double 'repository' }
  let(:producer) { double 'producer' }
  let(:records) { [double(etag: 'etag1'), double(etag: 'etag2')] }

  describe '#handle_records' do
    context 'when records is empty' do
      let(:records) { [] }

      it 'does not produce any records' do
        expect(repository).not_to receive(:get)
        expect(producer).not_to receive(:produce)
        expect(producer).not_to receive(:finalize)
        expect(repository).not_to receive(:store)

        subject.handle_records records
      end
    end

    context 'when all provided records already exists in the database' do
      it 'does not produce any records' do
        expect(repository).to receive(:get).with(records[0].etag).and_return 'something1'
        expect(repository).to receive(:get).with(records[1].etag).and_return 'something2'
        expect(producer).not_to receive(:produce)
        expect(producer).not_to receive(:finalize)
        expect(repository).not_to receive(:store)

        subject.handle_records records
      end
    end

    context 'when only some records already exists in the database' do
      it 'does not produce any records' do
        expect(repository).to receive(:get).with(records[0].etag).and_return 'something1'
        expect(repository).to receive(:get).with(records[1].etag).and_return nil
        expect(producer).to receive(:produce).with([records[1]])
        expect(producer).to receive(:finalize)
        expect(repository).to receive(:store).with([records[1]])

        subject.handle_records records
      end
    end
  end
end
