# frozen_string_literal: true

require 'register_common/compressors/gzip_writer'
require 'register_sources_dk/config/elasticsearch'
require 'register_sources_dk/repository'

require_relative 'config/settings'
require_relative 'records_producer'

module RegisterIngesterDk
  class RecordsHandler
    def initialize(repository: nil, producer: nil)
      @repository = repository || RegisterSourcesDk::Repository.new(
        client: RegisterSourcesDk::Config::ELASTICSEARCH_CLIENT,
        index: RegisterSourcesDk::Config::ELASTICSEARCH_INDEX
      )
      @producer = producer || RecordsProducer.new(stream_name: ENV.fetch('DK_STREAM', nil))
    end

    def handle_records(records)
      new_records = records.reject { |record| repository.get(record.etag) }

      return if new_records.empty?

      producer.produce(new_records)
      producer.finalize

      repository.store(new_records)
    end

    private

    attr_reader :repository, :producer
  end
end
