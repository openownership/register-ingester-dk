require 'register_ingester_dk/config/settings'
require 'register_ingester_dk/config/adapters'
require 'register_ingester_dk/record_serializer'
require 'register_common/services/publisher'

module RegisterIngesterDk
  class RecordsProducer
    def initialize(stream_name: nil, kinesis_adapter: nil, buffer_size: nil, serializer: nil)
      stream_name ||= ENV['DK_STREAM']
      kinesis_adapter ||= RegisterIngesterDk::Config::Adapters::KINESIS_ADAPTER
      buffer_size ||= 50
      serializer ||= RecordSerializer.new

      @publisher = stream_name.present? ? RegisterCommon::Services::Publisher.new(
        stream_name: stream_name,
        kinesis_adapter: kinesis_adapter,
        buffer_size: buffer_size,
        serializer: serializer
      ) : nil
    end

    def produce(records)
      return unless publisher

      records.each do |record|
        publisher.publish(record)
      end
    end

    def finalize
      return unless publisher

      publisher.finalize
    end

    private

    attr_reader :publisher
  end
end
