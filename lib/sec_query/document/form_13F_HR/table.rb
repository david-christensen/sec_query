module SecQuery
  module Document
    class Form13F_HR
      class Table
        attr_reader :raw_table

        def initialize(table)
          @raw_table = table
          @table = table.map {|r| transform_keys(r) } if table.is_a?(Array)
        end

        def to_json
          @table.to_json
        end

        private

        def transform_keys(row)
          {}.tap do |hsh|
            hsh['name_of_issuer'] = row['nameofissuer']
            hsh['title_of_class'] = row['titleofclass']
            hsh['cusip'] = row['cusip']
            hsh['value'] = row['value']
            hsh['other_manager'] = row['othermanager']

            if row['shrsorprnamt']
              hsh['shrs_or_prn_amt'] = {
                'amount' => row['shrsorprnamt']['sshprnamt'],
                'type' => row['shrsorprnamt']['sshprnamttype']
              }
            end

            if row['votingauthority']
              hsh['voting_authority'] = {
                'sole' => row['votingauthority']['sole'],
                'shared' => row['votingauthority']['shared'],
                'none' => row['votingauthority']['none']
              }
            end
          end
        end

        def respond_to_missing?(name, include_private = false)
          @table.respond_to?(name, include_private)
        end

        def method_missing(method, *args, &block)
          @table.public_send(method, *args, &block)
        end
      end
    end
  end
end
