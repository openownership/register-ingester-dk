require 'register_ingester_dk/config/settings'
require 'register_ingester_dk/config/adapters'

require 'register_ingester_dk/clients/dk_client'
require 'register_sources_dk/structs/record'
require 'register_ingester_dk/records_handler'

module RegisterIngesterDk
  module Apps
    class Ingester
      CHUNK_SIZE=50

      def self.bash_call(args)
        Ingester.new.call
      end

      def initialize(records_handler: nil, dk_client: nil)
        @records_handler = records_handler || RecordsHandler.new
        @dk_client = dk_client || Clients::DkClient.new(ENV['DK_CVR_USERNAME'], ENV['DK_CVR_PASSWORD'])
      end

      def call
        dk_client.all_records.lazy.each_slice(CHUNK_SIZE) do |records|
          records = records.map { |record| RegisterSourcesDk::Record[record] }.map(&:Vrdeltagerperson).compact

          next if records.empty?

          records_handler.handle_records records
        end
      end

      private

      attr_reader :records_handler, :dk_client
    end
  end
end
