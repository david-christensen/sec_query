module SecQuery
  module Document
    module Parsers
      class Schedule13gHtm
        attr_reader :link, :html

        def initialize(html, link)
          @html = html
          @link = link
        end

        def lines
          @lines ||= @file_string.split("\n")
        end

        def cusip
          @cusip ||= find_cusip_method_one
          @cusip ||= find_cusip_method_two
          @cusip ||= find_cusip_method_three
          @cusip ||= find_cusip_method_four
          @cusip ||= find_cusip_method_five
          @cusip ||= find_cusip_method_six
          @cusip ||= find_cusip_method_seven
          @cusip ||= find_cusip_method_eight
          @cusip ||= find_cusip_method_nine
          @cusip ||= find_cusip_method_ten
          @cusip ||= find_cusip_method_eleven
          @cusip ||= find_cusip_method_twelve
          @cusip ||= find_cusip_method_thirteen
          @cusip ||= find_in_text_tag
        end

        private

          def find_cusip_method_one
          text = @html&.at('font:contains("(CUSIP Number)")')&.parent&.previous&.search('font')&.text
          return unless cusip_match?(text)
          text
        end

        def find_cusip_method_two
          text = @html&.at('font:contains("(CUSIP Number)")')&.parent&.previous&.previous&.text&.gsub(/\p{Z}/, ' ')&.strip
          text = @html&.at('font:contains("(CUSIP Number)")')&.parent&.previous&.previous&.text&.gsub(/\p{Z}/, ' ')&.strip
          text ||= @html&.at('font:contains("(CUSIP Number)")')&.parent&.previous&.previous&.previous&.previous&.text&.gsub(/\p{Z}/, ' ')&.strip
          text ||= @html&.at('tr:contains("(CUSIP Number)")')&.previous&.text&.gsub(/\p{Z}/, ' ')&.strip
          return unless cusip_match?(text)
          text
        end

        def find_cusip_method_three
          text = @html.at('p:contains("CUSIP")')&.text&.gsub(/\s+/m, ' ')&.gsub(/\p{Z}/, ' ')&.gsub('Number:', '')&.strip&.split(' ')&.last
          return unless cusip_match?(text)
          text
        end

        def find_cusip_method_four
          text = @html.at('p:contains("CUSIP")')&.previous&.previous&.text&.gsub(/\p{Z}/, ' ')&.strip
          text = nil unless cusip_match?(text)
          text ||= @html.at('p:contains("CUSIP")')&.previous&.previous&.previous&.previous&.text&.gsub(/\p{Z}/, ' ')&.strip
          return unless cusip_match?(text)
          text
        end

        def find_cusip_method_five
          text = @html.at('td:contains("CUSIP")')&.next&.next&.text&.gsub(/\p{Z}/, ' ')&.gsub('Number:', '')&.strip&.split(' ')&.last
          text ||= @html.at('td:contains("CUSIP")')&.parent&.previous&.previous&.text&.gsub(/\p{Z}/, ' ')&.gsub('Number:', '')&.strip&.split(' ')&.last
          return unless cusip_match?(text)
          text
        end

        def find_cusip_method_six
          text = @html&.at('font:contains("(CUSIP Number)")')&.parent&.previous&.previous&.previous&.previous&.text&.gsub(/\p{Z}/, ' ')&.strip
          return unless cusip_match?(text)
          text
        end

        def find_cusip_method_seven
          return unless @html&.at('div:contains("CUSIP No: ")')&.text
          text_array = @html&.at('div:contains("CUSIP No: ")')&.text&.split(' ')
          return unless text_array.is_a?(Array) && text_array.count == 3
          cusip_txt, no_text, cusip_value = text_array
          return unless cusip_txt == 'CUSIP' && no_text == 'No:'
          return unless cusip_match?(cusip_value)
          cusip_value
        end

        def find_cusip_method_eight
          return unless @html&.at('td:contains("CUSIP No. ")')&.text
          text_array = @html&.at('td:contains("CUSIP No. ")')&.text&.split(' ')
          return unless text_array.is_a?(Array) && text_array.count == 3
          cusip_txt, no_text, cusip_value = text_array
          return unless cusip_txt == 'CUSIP' && no_text == 'No.'
          return unless cusip_match?(cusip_value)
          cusip_value
        end

        def find_cusip_method_nine
          text = @html&.at('font:contains("(CUSIP Number)")')&.parent&.previous&.text&.gsub(/\p{Z}/, ' ')&.strip
          text ||= @html&.at('td:contains("(CUSIP Number)")')&.parent&.previous&.previous&.text&.gsub(/\p{Z}/, ' ')&.strip
          return unless cusip_match?(text)
          text
        end

        def find_cusip_method_ten
          return unless @html.xpath('/html/body/document/type/sequence/filename/description/text/div/div[1]/div[1]/div[8]/div[2]')&.text == "(CUSIP Number)"
          text = @html.xpath('/html/body/document/type/sequence/filename/description/text/div/div[1]/div[1]/div[8]/div[1]')&.text&.gsub(/\p{Z}/, ' ')&.strip
          return unless cusip_match?(text)
          text
        end

        def find_cusip_method_eleven
          return unless @html&.at('font:contains("CUSIP No.")')&.text || @html&.at('td:contains("CUSIP No.")')&.text
          text_array = @html&.at('font:contains("CUSIP No.")')&.text&.gsub(/\p{Z}/, ' ')&.split(' ')
          text_array ||= @html&.at('td:contains("CUSIP No.")')&.text&.gsub(/\p{Z}/, ' ')&.split(' ')
          return unless text_array.is_a?(Array) && text_array.count == 3
          cusip_txt, no_text = text_array.shift(2)
          cusip_value = text_array.join(' ').strip
          return unless cusip_txt == 'CUSIP' && no_text == 'No.'
          return unless cusip_match?(cusip_value)
          cusip_value
        end

        def find_cusip_method_twelve
          text = @html&.at('font:contains("CUSIP")')&.next&.text&.gsub(/\p{Z}/, ' ')&.strip
          text = nil unless cusip_match?(text)
          text ||= @html&.at('font:contains("CUSIP")')&.previous&.text&.gsub(/\p{Z}/, ' ')&.strip
          return unless cusip_match?(text)
          text
        end

        def find_cusip_method_thirteen
          return unless @html&.at('b:contains("CUSIP No. ")')&.text
          text_array = @html&.at('b:contains("CUSIP No. ")')&.text&.split(' ')
          cusip_txt, no_text = text_array.shift(2)
          cusip_value = text_array.join(' ').strip
          return unless cusip_txt == 'CUSIP' && no_text == 'No.'
          return unless cusip_match?(cusip_value)
          cusip_value
        end

        def find_in_text_tag
          return unless @html&.at('text:contains("CUSIP Number:    ")')&.text
          lines = @html&.at('text:contains("CUSIP Number:    ")').text.split("\n")
          line = lines.find {|line| line.include?('CUSIP Number: ')}
          return unless line
          text_array = line.split(' ')
          cusip_txt, no_text = text_array.shift(2)
          cusip_value = text_array.join(' ').strip
          return unless cusip_match?(cusip_value)
          cusip_value
        end

        def cusip_match?(value)
          return false unless value.respond_to?(:match)
          return true if value.match(/[0-9A-Z]{9}|[0-9A-Z]{8}|[0-9A-Z]{7}/) && value.match(/[0-9]/)
          return true if value.match(/^[0-9A-Z]{6}\s[0-9A-Z]{2}\s[0-9A-Z]{1}$/) && value.match(/[0-9]/)
          return true if value.match(/^[0-9A-Z]{6}\s\s[0-9A-Z]{2}\s\s[0-9A-Z]{1}$/) && value.match(/[0-9]/)
          return true if value.match(/^[0-9A-Z]{6}[-]{1}[0-9A-Z]{2}[-]{1}[0-9A-Z]{1}$/) && value.match(/[0-9]/)
          return true if value.match(/^[0-9A-Z]{6}\s[0-9A-Z]{3}$/) && value.match(/[0-9]/)
          return true if value.match(/^[0-9A-Z]{6}$/) && value.match(/[0-9]/)
          return true if value.match(/^[0-9A-Z]{7}$/) && value.match(/[0-9]/)
          return true if value.match(/^[0-9A-Z]{8}$/) && value.match(/[0-9]/)
          return true if value.match(/^[0-9A-Z]{9}$/) && value.match(/[0-9]/)
          false
        end
      end
    end
  end
end
