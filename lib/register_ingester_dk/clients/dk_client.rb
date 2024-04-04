# frozen_string_literal: true

require 'active_support/core_ext/object/blank'
require 'elasticsearch'
require 'register_common/elasticsearch/query'

module RegisterIngesterDk
  module Clients
    class DkClient
      PAGE_SIZE = 500

      def initialize(username, password)
        @client = Elasticsearch::Client.new(
          url: "http://#{username}:#{password}@distribution.virk.dk:80"
        )
      end

      def all_records
        q = {
          index: 'cvr-permanent',
          type: 'deltager',
          body: {
            query: {
              match: {
                'Vrdeltagerperson.enhedstype': 'PERSON'
              }
            },
            sort: ['_doc'],
            size: PAGE_SIZE
          }
        }
        Enumerator.new do |yielder|
          RegisterCommon::Elasticsearch::Query.search_scroll(@client, q) do |hit|
            yielder << hit['_source']
          end
        end
      end
    end
  end
end
