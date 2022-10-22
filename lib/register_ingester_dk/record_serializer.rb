require 'json'

require 'register_common/compressors/gzip_writer'

module RegisterIngesterDk
  class RecordSerializer
    def initialize(zip_writer: RegisterCommon::Compressors::GzipWriter.new)
      @zip_writer = zip_writer
    end

    def serialize(record)
      stream = zip_writer.open_stream(StringIO.new)
      stream << record.to_h.to_json
      zip_writer.close_stream(stream)
    end

    private

    attr_reader :zip_writer
  end
end
