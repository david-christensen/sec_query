# encoding: UTF-8

module SecQuery
  # => SecQuery::FilingDetail
  # SecQuery::FilingDetail requests and parses Filing Detail for any given SecQuery::Filing
  class FilingDetail
    COLUMNS = [
      :link,:filing_date, :accepted_date, :period_of_report, :sec_access_number, :document_count, :format_files, :data_files,
      :filer_span, :subject_span
    ]

    attr_accessor(*COLUMNS)

    def initialize(filing_detail)
      COLUMNS.each do |column|
        instance_variable_set("@#{ column }", filing_detail[column])
      end
    end

    def filer
      return unless filer_span
      return @filer if @filer
      splitter = filer_span.text.include?('(Filer)') ? '(Filer)' : '(Filed by)'
      filer_span.text.split(splitter)
      name, remainder = filer_span.text.split(splitter).map(&:strip)
      cik = remainder.split(' ').second

      irs_no_index = filer_span.parent.at('p:contains("IRS No.")').children.map(&:text).find_index{|s| s == "IRS No."}
      irs_no = filer_span.parent.at('p:contains("IRS No.")').children.map(&:text)[irs_no_index + 2]

      state_of_incorp_index = filer_span.parent.at('p:contains("IRS No.")').children.map(&:text).find_index{|s| s == " | State of Incorp.: "}
      state_of_incorp = filer_span.parent.at('p:contains("IRS No.")').children.map(&:text)[state_of_incorp_index + 1]

      fiscal_year_end_index = filer_span.parent.at('p:contains("IRS No.")').children.map(&:text).find_index{|s| s == " | Fiscal Year End: "}
      fiscal_year_end = filer_span.parent.at('p:contains("IRS No.")').children.map(&:text)[fiscal_year_end_index + 1]

      type_index = filer_span.parent.at('p:contains("IRS No.")').children.map(&:text).find_index{|s| s == "Type: "}
      filing_type = filer_span.parent.at('p:contains("IRS No.")').children.map(&:text)[type_index + 1]

      act_index = filer_span.parent.at('p:contains("IRS No.")').children.map(&:text).find_index{|s| s == " | Act: "}
      act = act_index ?  filer_span.parent.at('p:contains("IRS No.")').children.map(&:text)[act_index + 1] : nil

      film_no_index = filer_span.parent.at('p:contains("IRS No.")').children.map(&:text).find_index{|s| s == " | Film No.: "}
      film_no = film_no_index ?  filer_span.parent.at('p:contains("IRS No.")').children.map(&:text)[film_no_index + 1] : nil

      file_no_index = filer_span.parent.at('p:contains("IRS No.")').children.map(&:text).find_index{|s| s == " | File No.: "}
      file_no = file_no_index ?  filer_span.parent.at('p:contains("IRS No.")').children.map(&:text)[file_no_index + 1] : nil

      sic_index = filer_span.parent.at('p:contains("IRS No.")').children.map(&:text).find_index{|s| s == "SIC"}
      sic = filer_span.parent.at('p:contains("IRS No.")').children.map(&:text)[sic_index+2]
      sic_text = filer_span.parent.at('p:contains("IRS No.")').children.map(&:text)[sic_index+3].strip

      office = filer_span.parent.at('p:contains("IRS No.")').children.map(&:text).last

      @filer = OpenStruct.new(
        name: name,
        cik: cik,
        irs_no: irs_no,
        state_of_incorp: state_of_incorp,
        fiscal_year_end: fiscal_year_end,
        filing_type: filing_type,
        act: act,
        film_no: film_no,
        file_no: file_no,
        sic: sic,
        sic_text: sic_text,
        office: office
      )
    end

    def subject
      return @subject if @subject
      return unless subject_span
      name = subject_span.text.split('(Subject)').first.strip

      # should be "CIK: 000123"
      cik_str = subject_span.text.split('(Subject)').second.gsub('(see all company filings)', '').strip
      cik = cik_str[0..4] == "CIK: " ? cik_str.split(' ').second : nil

      line_two_array = subject_span.next.next.text.split(' | ')
      type_str_index = line_two_array.find_index {|s| s.include?('Type:')}
      type_str = line_two_array.delete_at(type_str_index)
      remainder, filing_type = type_str.split('Type: ')
      line_two_array << remainder

      irs_no_index = line_two_array.find_index{|s| s.start_with? "IRS No."}
      irs_no = irs_no_index ? line_two_array[irs_no_index]&.gsub('IRS No.: ','')&.strip : nil

      state_of_incorp_index = line_two_array.find_index{|s| s.start_with? "State of Incorp.:"}
      state_of_incorp = state_of_incorp_index ? line_two_array[state_of_incorp_index]&.gsub('State of Incorp.:','')&.strip : nil

      fiscal_year_end_index = line_two_array.find_index{|s| s.start_with? "Fiscal Year End: "}
      fiscal_year_end = fiscal_year_end_index ? line_two_array[fiscal_year_end_index].gsub('Fiscal Year End: ','')&.strip : nil

      film_no_index = line_two_array.find_index{|s| s.start_with? "Film No.:"}
      film_no = film_no_index ? line_two_array[film_no_index]&.gsub('Film No.:','')&.strip : nil

      file_no_index = line_two_array.find_index{|s| s.start_with? "File No.:"}
      file_no = file_no_index ? line_two_array[file_no_index]&.gsub('File No.:','').strip : nil

      act_index = line_two_array.find_index{|s| s.start_with? "Act:"}
      act = act_index ? line_two_array[act_index].gsub('Act:','').strip : nil

      @subject = OpenStruct.new(
        name: name,
        cik: cik,
        irs_no: irs_no,
        state_of_incorp: state_of_incorp,
        fiscal_year_end: fiscal_year_end,
        filing_type: filing_type,
        act: act,
        film_no: film_no,
        file_no: file_no
      )
    end

    def txt_data_files
      return @txt_data_files if @txt_data_files
      return unless data_files
      @txt_data_files = data_files.select {|f| f['Document']['text'].length > 4 && f['Document']['text'][-4..-1] == '.txt' }
    end

    def txt_format_files
      return @txt_format_files if @txt_format_files
      return unless format_files
      @txt_format_files = format_files.select {|f| f['Document']['text'].length > 4 && f['Document']['text'][-4..-1] == '.txt' }
    end

    def xml_data_files
      return @xml_data_files if @xml_data_files
      return unless data_files
      @xml_data_files = data_files.select {|f| f['Document']['text'].length > 4 && f['Document']['text'][-4..-1] == '.xml' }
    end

    def xml_format_files
      return @xml_format_files if @xml_format_files
      return unless format_files
      @xml_format_files = format_files.select {|f| f['Document']['text'].length > 4 && f['Document']['text'][-4..-1] == '.xml' }
    end

    def self.fetch(uri)
      document = Nokogiri::HTML(URI.open(uri.gsub('http:', 'https:')))
      filing_date = document.xpath('//*[@id="formDiv"]/div[2]/div[1]/div[2]').text
      accepted_date = document.xpath('//*[@id="formDiv"]/div[2]/div[1]/div[4]').text
      period_of_report = document.xpath('//*[@id="formDiv"]/div[2]/div[2]/div[2]').text
      sec_access_number = document.xpath('//*[@id="secNum"]/text()').text.strip
      document_count = document.xpath('//*[@id="formDiv"]/div[2]/div[1]/div[6]').text.to_i
      format_files_table = document.xpath("//table[@summary='Document Format Files']")
      data_files_table = document.xpath("//table[@summary='Data Files']")

      format_files = (parsed = parse_files(format_files_table)) && (parsed || [])
      data_files = (parsed = parse_files(data_files_table)) && (parsed || [])
      filer_span = document.at('span:contains("(Filer)")') || document.at('span:contains("(Filed by)")')
      subject_span = document.at('span:contains("(Subject)")')

      new(
        uri: uri,
        filing_date: filing_date,
        accepted_date: accepted_date,
        period_of_report: period_of_report,
        sec_access_number: sec_access_number,
        document_count: document_count,
        format_files: format_files,
        data_files: data_files,
        filer_span: filer_span,
        subject_span: subject_span
      )
    end

    def self.parse_files(format_files_table)
      # get table headers
      headers = []
      format_files_table.xpath('//th').each do |th|
        headers << th.text
      end

      # get table rows
      rows = []
      format_files_table.xpath('//tr').each_with_index do |row, i|
        rows[i] = {}
        row.xpath('td').each_with_index do |td, j|
          if td.children.first && td.children.first.name == 'a'
            relative_url = td.children.first.attributes.first[1].value
            rows[i][headers[j]] = {
                'link' => "https://www.sec.gov#{relative_url}",
                'text' => td.text.gsub(/\A\p{Space}*/, '')
            }
          else
            rows[i][headers[j]] = td.text.gsub(/\A\p{Space}*/, '')
          end
        end
      end

      rows.reject(&:empty?)
    end
  end
end
