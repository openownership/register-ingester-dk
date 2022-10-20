require 'register_ingester_dk/config/settings'
require 'register_sources_dk/config/elasticsearch'
require 'register_sources_dk/repositories/deltagerperson_repository'
require 'register_ingester_dk/records_producer'

module RegisterIngesterDk
  class RecordsHandler
    def initialize(repository: nil, producer: nil, bods_publisher: nil, entity_resolver: nil, bods_mapper: nil)
      @repository = repository || RegisterSourcesDk::Repositories::DeltagerpersonRepository.new(
        client: RegisterSourcesDk::Config::ELASTICSEARCH_CLIENT)
      @producer = producer || RecordsProducer.new
    end

    def handle_records(records)
      new_records = records.reject { |record| repository.get(record.etag) }

      return if new_records.empty?

      print("Inserting new records: ", records.map(&:to_h), "\n\n")
      producer.produce(new_records)
      producer.finalize

      repository.store(new_records)
    end

    private

    attr_reader :repository, :producer
  end
end
