require 'json'

module RegisterIngesterDk
  class RecordSerializer
    def serialize(record)
      record.to_h.to_json
    end
  end
end
