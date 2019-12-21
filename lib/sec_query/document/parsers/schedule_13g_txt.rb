module SecQuery
  module Document
    module Parsers
      class Schedule13gTxt
        attr_reader :link

        def initialize(file_string, link)
          @file_string = file_string
          @link = link
        end

        def lines
          @lines ||= @file_string.split("\n")
        end

        # def cusip
        #   @cusip ||= lines.find {|l| l.include?('CUSIP Number: ') }&.split('CUSIP Number: ')&.last&.strip
        #   @cusip ||= lines.find_index('(CUSIP NUMBER)') ? lines[lines.find_index('(CUSIP NUMBER)') - 1]&.strip : nil
        #   @cusip ||= lines.find_index {|l| l.include?('(CUSIP Number)')} ? lines[lines.find_index {|l| l.include?('(CUSIP Number)')} - 1]&.strip : nil
        # end

        def cusip
          # @cusip ||= look_for_cusip(lines.find_index {|l| l.include?('CUSIP Number: ')})
          # @cusip ||= look_for_cusip(lines.find_index {|l| l.include?('(CUSIP NUMBER)')})
          # @cusip ||= look_for_cusip(lines.find_index {|l| l.include?('(CUSIP Number)')})
          @cusip ||= look_for_cusip(lines.find_index {|l| l.include?('CUSIP')})
        end

        private

        # TODO - There is probably a better way to parse this one.
        # "<p style=\"margin:0in 0in .0001pt;\"><font size=\"2\" face=\"Times New Roman\" style=\"font-size:10.0pt;\">CUSIP   No.&nbsp;UO387J108</font></p>    </td>"
        def parse_cusip_font_tag
          line = lines.find {|l| l.include?(">CUSIP   No.&nbsp\;") }
          begin
            line[line.index(">CUSIP   No.&nbsp\;")..-1].split("<").first.gsub(">CUSIP   No.&nbsp\;", '')
          rescue
            nil
          end
        end

        def look_for_cusip(line_index, offset = 0)
          return unless line_index
          return if offset > 7
          if offset > 0
            return cusip_match(lines[(line_index - offset)])&.to_s if cusip_match?(lines[(line_index - offset)])
            return cusip_match(lines[line_index + offset])&.to_s if cusip_match?(lines[line_index + offset])
          else
            return cusip_match(lines[line_index])&.to_s if cusip_match?(lines[line_index])
          end
          look_for_cusip(line_index, offset + 1)
        end

        def cusip_match(value)
          return unless value.respond_to?(:match)
          return value.match /[0-9A-Z]{9}|[0-9A-Z]{8}|[0-9A-Z]{7}/ if value.match /[0-9A-Z]{9}|[0-9A-Z]{8}|[0-9A-Z]{7}/
          return value.match /^[0-9A-Z]{6}\s[0-9A-Z]{2}\s[0-9A-Z]{1}$/ if value.match /^[0-9A-Z]{6}\s[0-9A-Z]{2}\s[0-9A-Z]{1}$/
          return value.match /^[0-9A-Z]{6}\s\s[0-9A-Z]{2}\s\s[0-9A-Z]{1}$/ if value.match /^[0-9A-Z]{6}\s\s[0-9A-Z]{2}\s\s[0-9A-Z]{1}$/
          return value.match /^[0-9A-Z]{6}[-]{1}[0-9A-Z]{2}[-]{1}[0-9A-Z]{1}$/ if value.match /^[0-9A-Z]{6}[-]{1}[0-9A-Z]{2}[-]{1}[0-9A-Z]{1}$/
          return value.match /^[0-9A-Z]{6}\s[0-9A-Z]{3}$/ if value.match /^[0-9A-Z]{6}\s[0-9A-Z]{3}$/
          return value.match /^[0-9A-Z]{6}$/ if value.match /^[0-9A-Z]{6}$/
          return value.match /^[0-9A-Z]{7}$/ if value.match /^[0-9A-Z]{7}$/
          return value.match /^[0-9A-Z]{8}$/ if value.match /^[0-9A-Z]{8}$/
          return value.match /^[0-9A-Z]{9}$/ if value.match /^[0-9A-Z]{9}$/
          nil
        end

        def cusip_match?(value)
          !!cusip_match(value)
        end
      end
    end
  end
end
