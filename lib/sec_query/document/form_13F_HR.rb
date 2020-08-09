module SecQuery
  module Document
    class Form13F_HR
      attr_reader :type, :period_of_report, :subject_to_section_16

      def initialize(header, form, table)
        @header = header
        @form = form
        @table = table
      end

      def to_h
        {
          'header' => @header,
          'form' => @form,
          'table' => @table
        }
      end

      def self.fetch(primary_doc_url, table_doc_url)
        html = Nokogiri::HTML(URI.open(primary_doc_url))
        # document = Hash.from_xml(html.xpath('//body//ownershipdocument').to_s)&.dig('ownershipdocument') || {}
        # new(document)
        # Hash.from_xml(html.xpath('//body//informationtable').to_s)['infotable']
        #
        # load 'sec_query.rb'
        # cik = '0001067983'
        # filing = SecQuery::Filing.find(cik, 0, 1, {type: '13F-HR'}).first
        #
        #

        hsh = Hash.from_xml(html.xpath('//body/edgarsubmission').to_xml)

        header_data = hsh['edgarsubmission']['headerdata']
        form_data = hsh['edgarsubmission']['formdata']

        html = Nokogiri::HTML(URI.open(table_doc_url))
        hsh = Hash.from_xml(html.xpath('//body/informationtable').to_xml)

        table = hsh['informationtable']['infotable']

        new(header_data, form_data, table)
      end
    end
  end
end
