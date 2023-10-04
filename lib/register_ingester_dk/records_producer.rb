# frozen_string_literal: true

require 'register_common/services/publisher'

require_relative 'config/adapters'
require_relative 'config/settings'
require_relative 'record_serializer'

module RegisterIngesterDk
  class RecordsProducer
    def initialize(stream_name: nil, kinesis_adapter: nil, s3_adapter: nil, buffer_size: nil, serializer: nil)
      stream_name ||= ENV.fetch('DK_STREAM', nil)
      kinesis_adapter ||= RegisterIngesterDk::Config::Adapters::KINESIS_ADAPTER
      s3_adapter ||= RegisterIngesterDk::Config::Adapters::S3_ADAPTER
      buffer_size ||= 25
      serializer ||= RecordSerializer.new

      @publisher = if stream_name.present?
                     RegisterCommon::Services::Publisher.new(
                       stream_name:,
                       kinesis_adapter:,
                       buffer_size:,
                       serializer:,
                       s3_adapter:,
                       s3_prefix: 'large-dk',
                       s3_bucket: ENV.fetch('BODS_S3_BUCKET_NAME', nil)
                     )
                   end
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
