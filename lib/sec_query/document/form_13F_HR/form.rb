module SecQuery
  module Document
    class Form13F_HR
      class Form
        attr_reader :cover_page, :signature_block, :summary_page, :raw_form

        def initialize(form)
          @raw_form = form
          @cover_page = transform_cover_page(form['coverpage'] || {})
          @signature_block = transform_signature_block(form['signatureblock'] || {})
          @summary_page = transform_summary_page(form['summarypage'] || {})
          @form = form.map {|r| transform_keys(r) } if form.is_a?(Array)
        end

        def to_h
          {
            'cover_page' => @cover_page,
            'signature_block' => @signature_block,
            'summary_page' => @summary_page
          }
        end

        def to_json
          to_h.to_json
        end

        private

        def transform_summary_page(raw_summary_page)
          {}.tap do |hsh|
            hsh['table_entry_total'] = raw_summary_page['tableentrytotal']
            hsh['table_value_total'] = raw_summary_page['tablevaluetotal']
            hsh['is_confidential_omitted'] = raw_summary_page['isconfidentialomitted']
            hsh['other_managers_2_info'] = raw_summary_page['othermanagers2info']

            if hsh['other_managers_2_info'] && hsh['other_managers_2_info']['othermanager2']
              hsh['other_managers_2_info']['other_manager_2'] = hsh['other_managers_2_info'].delete('othermanager2')

              hsh['other_managers_2_info']['other_manager_2'].each do |row|
                row['sequence_number'] = row.delete('sequencenumber')
                row['other_manager'] = row.delete('othermanager')
                if row['other_manager']
                  row['other_manager']['form13f_file_number'] = row['other_manager'].delete('form13ffilenumber')
                end
              end
            end
          end
        end

        def transform_signature_block(raw_signature_block)
          {}.tap do |hsh|
            hsh.merge!(raw_signature_block)
            hsh['state_or_country'] = hsh.delete('stateorcountry')
            hsh['signature_date'] = hsh.delete('signaturedate')
          end
        end

        def transform_cover_page(raw_coverpage)
          {}.tap do |hsh|
            hsh['report_calendar_or_quarter'] = raw_coverpage['reportcalendarorquarter']
            hsh['is_amendment'] = raw_coverpage['isamendment']

            if raw_coverpage['filingmanager']
              hsh['filing_manager'] = raw_coverpage['filingmanager']
              hsh['filing_manager']['address']['zip_code'] = hsh['filing_manager']['address'].delete('zipcode')
              hsh['filing_manager']['address']['state_or_country'] = hsh['filing_manager']['address'].delete('stateorcountry')
            end

            hsh['report_type'] = raw_coverpage['reporttype']
            hsh['form13f_file_number'] = raw_coverpage['form13ffilenumber']

            if raw_coverpage['othermanagersinfo']
              hsh['other_managers_info'] = raw_coverpage['othermanagersinfo']
              if hsh['other_managers_info']['othermanager']
                hsh['other_managers_info']['other_manager'] = hsh['other_managers_info'].delete('othermanager')
                if hsh['other_managers_info']['other_manager']['form13ffilenumber']
                  hsh['other_managers_info']['other_manager']['form13f_file_number'] = hsh['other_managers_info']['other_manager'].delete('form13ffilenumber')
                end
              end
            end

            if raw_coverpage['votingauthority']
              hsh['voting_authority'] = {
                'sole' => raw_coverpage['votingauthority']['sole'],
                'shared' => raw_coverpage['votingauthority']['shared'],
                'none' => raw_coverpage['votingauthority']['none']
              }
            end

            hsh['provide_info_for_instruction_5'] = raw_coverpage['provideinfoforinstruction5']
          end
        end

        def respond_to_missing?(name, include_private = false)
          @form.respond_to?(name, include_private)
        end

        def method_missing(method, *args, &block)
          @form.public_send(method, *args, &block)
        end
      end
    end
  end
end
