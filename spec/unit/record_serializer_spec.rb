# frozen_string_literal: true

require 'json'
require 'register_ingester_dk/record_serializer'

RSpec.describe RegisterIngesterDk::RecordSerializer do
  subject { described_class.new }

  describe '#serialize' do
    context 'when record is a hash' do
      let(:record) { { 'a' => 'b' } }

      it 'converts to JSON' do
        result = subject.serialize record

        expect(result).to eq('{"a":"b"}')
      end
    end

    context 'when record cannot be converted to a hash' do
      let(:record) { 'abc' }

      it 'raises an error' do
        expect { subject.serialize record }.to raise_error NoMethodError
      end
    end
  end
end
