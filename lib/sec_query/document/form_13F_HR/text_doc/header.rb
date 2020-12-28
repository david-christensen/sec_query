module SecQuery
  module Document
    class Form13F_HR
      class TextDoc
        class Header
          def initialize(cik, submission_type, period_of_report)
            @cik = cik
            @submission_type = submission_type
            @period_of_report = period_of_report
          end

          def to_h
            {
              'submissiontype' => @submission_type,
              'periodofreport' => @period_of_report,
              'filerinfo' => {
                'filer' => {
                  'credentials' => {
                    'cik' => @cik
                  }
                }
              }
            }
          end
        end
      end
    end
  end
end
