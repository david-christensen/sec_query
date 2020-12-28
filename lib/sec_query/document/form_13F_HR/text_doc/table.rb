module SecQuery
  module Document
    class Form13F_HR
      class TextDoc
        class Table
          class << self
            def parse(lines)
              column_index = lines.find_index {|line| line.include?('COLUMN 1') }
              column_widths = lines[column_index+4].split(' ')

              index_list = []
              column_widths.each_with_index do |width, index|
                if index == 0
                  index_list << [0, (width.length - 1)]
                elsif index == (column_widths.count - 1)
                  start = index_list.last.last + 2
                  index_list << [start, (start + width.length)]
                else
                  start = index_list.last.last + 2
                  index_list << [start, (start + (width.length - 1))]
                end
              end

              keys = []
              index_list.each { |first, last| keys << [lines[column_index+2][first..last].strip, lines[column_index+3][first..last].strip].join(' ').strip.gsub('/ ', '/') }
              index_list.each do |first, last|
                keys << [lines[column_index+2][first..last].strip, lines[column_index+3][first..last].strip].join(' ').strip.gsub('/ ', '/')
              end

              # keys don't quite match xml version - adjusting
              keys.map! do |key|
                if key == "VOTING SOLE"
                  'VOTING AUTHORITY SOLE'
                elsif key == "UTHORI SHARED"
                  'VOTING AUTHORITY SHARED'
                elsif key == "Y NONE"
                  'VOTING AUTHORITY NONE'
                elsif key == "OTHER MANAGERS"
                  'OTHER MANAGER'
                else
                  key
                end
              end

              table = []
              line_index = column_index + 6
              while !lines[line_index].include?('</TABLE>')
                line = lines[line_index]

                row = {}

                index_list.each_with_index do |first_and_last, index|
                  first, last = first_and_last
                  key = keys[index]
                  if key.start_with?('VOTING AUTHORITY')
                    row['votingauthority'] ||= {}
                    row['votingauthority'][key.split(' ').last.downcase] = line[first..last].split(',').join.strip
                  elsif key.include?('VALUE')
                    row['value'] = line[first..last].split(',').join.strip
                  elsif key == 'SHRS OR PRN AMT'
                    row['shrsorprnamt'] ||= {}
                    row['shrsorprnamt']['sshprnamt'] = line[first..last].split(',').join.strip
                  elsif key == 'SH/PRN'
                    row['shrsorprnamt'] ||= {}
                    row['shrsorprnamt']['sshprnamttype'] = line[first..last].strip
                  else
                    row[key.gsub(' ', '').downcase] = line[first..last].strip
                  end
                end

                table << row
                line_index += 1
              end

              table
            end
          end
        end
      end
    end
  end
end
