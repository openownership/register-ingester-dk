# frozen_string_literal: true

require 'register_sources_dk/structs/record'

require_relative '../clients/dk_client'
require_relative '../config/adapters'
require_relative '../config/settings'
require_relative '../records_handler'

module RegisterIngesterDk
  module Apps
    class Ingester
      CHUNK_SIZE = 500

      def self.bash_call(_args)
        Ingester.new.call
      end

      def initialize(records_handler: nil, dk_client: nil)
        @records_handler = records_handler || RecordsHandler.new
        @dk_client = dk_client || Clients::DkClient.new(
          ENV.fetch('DK_CVR_USERNAME', nil),
          ENV.fetch('DK_CVR_PASSWORD', nil)
        )
      end

      def call
        n = 0
        dk_client.all_records.lazy.each_slice(CHUNK_SIZE) do |records|
          n += records.count
          puts "[#{Time.now}] " + format('%9s', n)
          records = records.map do |record|
            RegisterSourcesDk::Record[record]
          end.map(&:Vrdeltagerperson).compact

          next if records.empty?

          records_handler.handle_records records
        end
      end

      private

      attr_reader :records_handler, :dk_client
    end
  end
end
