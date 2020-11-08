require_relative 'form_13F_HR/form'
require_relative 'form_13F_HR/table'

module SecQuery
  module Document
    class Form13F_HR
      attr_reader :type, :period_of_report, :table, :header, :form

      def initialize(header, form, table)
        @header = header

        @type = header['submissiontype']
        @period_of_report = header['periodofreport']
        @filer_info = {
          'live_test_flag' => header['filerinfo'] && header['filerinfo']['livetestflag'] || nil,
          'flags' => header['filerinfo'] && header['filerinfo']['flags'] || nil,
          'filer' => header['filerinfo'] && header['filerinfo']['filer'] || nil,
        } if header['filerinfo']

        @filer_cik = header['filerinfo'] &&
          header['filerinfo']['filer'] &&
          header['filerinfo']['filer']['credentials'] &&
          header['filerinfo']['filer']['credentials']['cik'] || nil


        @form = form.is_a?(Hash) ? Form.new(form) : form
        @table = table.is_a?(Array) ? Table.new(table) : table
      end

      def to_h
        {
          'type' => @type,
          'period_of_report' => @period_of_report,
          'filer_cik' => @filer_cik,
          'filer_info' => @filer_info,
          'form' => @form.respond_to?(:to_h) ? @form.to_h : @form,
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
