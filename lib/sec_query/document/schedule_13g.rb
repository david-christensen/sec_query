module SecQuery
  module Document
    class Schedule13g
      attr_reader :parser

      def initialize(parser)
        @parser = parser
      end

      def cusip
        parser&.cusip
      end

      def self.fetch(uri)
        if uri.end_with?('.htm')
          parser = SecQuery::Document::Parsers::Schedule13gHtm.new(Nokogiri::HTML(URI.open(uri)), uri)
        else
          parser = SecQuery::Document::Parsers::Schedule13gTxt.new(URI.open(uri) {|f| f.read }, uri)
        end

        new(parser)
      end
    end
  end
end
