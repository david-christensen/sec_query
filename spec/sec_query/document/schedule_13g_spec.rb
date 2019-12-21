include SecQuery
require 'spec_helper'

# Note: Shared Methods are available in spec_helper.rb

describe SecQuery::Document::Schedule13g do
  describe "Text Filing - type 1", vcr: { cassette_name: "schedule_13g_txt_one"} do
    let(:uri) { 'https://www.sec.gov/Archives/edgar/data/814133/000081413319000013/0000814133-19-000013.txt' }

    let(:document) { described_class.fetch(uri) }

    # For type 1 the CUSIP is on a line that looks like:
    # CUSIP Number: 13462K109
    it 'finds cusip' do
      expect(document.cusip).to eq '13462K109'
    end
  end

  describe "Text Filing - type 2", vcr: { cassette_name: "schedule_13g_txt_two"} do
    let(:uri) { 'https://www.sec.gov/Archives/edgar/data/80255/000008025517000887/sam13gdec16.txt' }

    let(:document) { described_class.fetch(uri) }

    # For type 2 the CUSIP section looks like:
    #
    # 100557107
    # (CUSIP NUMBER)
    #
    it 'finds cusip' do
      expect(document.cusip).to eq '100557107'
    end
  end

  S_P_500_TICKERS = ['AMGN', 'GILD', 'JCI', 'LLY', 'MDT', 'LYB', 'HSIC', 'GWW', 'MMM', 'ABT', 'ABBV', 'ABMD', 'ACN', 'ATVI', 'ADBE', 'AMD', 'AAP', 'AES', 'AMG', 'AFL', 'A', 'APD', 'AKAM', 'ALK', 'ALB', 'ARE', 'ALXN', 'ALGN', 'ALLE', 'AGN', 'ADS', 'LNT', 'ALL', 'GOOGL', 'GOOG', 'MO', 'AMZN', 'AMCR', 'AEE', 'AAL', 'AEP', 'AXP', 'AIG', 'AMT', 'AWK', 'AMP', 'ABC', 'AME', 'AMGN', 'APH', 'APC', 'ADI', 'ANSS', 'ANTM', 'AON', 'AOS', 'APA', 'AIV', 'AAPL', 'AMAT', 'APTV', 'ADM', 'ARNC', 'ANET', 'AJG', 'AIZ', 'ATO', 'T', 'ADSK', 'ADP', 'AZO', 'AVB', 'AVY', 'BHGE', 'BLL', 'BAC', 'BK', 'BAX', 'BBT', 'BDX', 'BRK.B', 'BBY', 'BIIB', 'BLK', 'HRB', 'BA', 'BKNG', 'BWA', 'BXP', 'BSX', 'BMY', 'AVGO', 'BR', 'BF.B', 'CHRW', 'COG', 'CDNS', 'CPB', 'COF', 'CPRI', 'CAH', 'KMX', 'CCL', 'CAT', 'CBOE', 'CBRE', 'CBS', 'CE', 'CELG', 'CNC', 'CNP', 'CTL', 'CERN', 'CF', 'SCHW', 'CHTR', 'CVX', 'CMG', 'CB', 'CHD', 'CI', 'XEC', 'CINF', 'CTAS', 'CSCO', 'C', 'CFG', 'CTXS', 'CLX', 'CME', 'CMS', 'KO', 'CTSH', 'CL', 'CMCSA', 'CMA', 'CAG', 'CXO', 'COP', 'ED', 'STZ', 'COO', 'CPRT', 'GLW', 'CTVA', 'COST', 'COTY', 'CCI', 'CSX', 'CMI', 'CVS', 'DHI', 'DHR', 'DRI', 'DVA', 'DE', 'DAL', 'XRAY', 'DVN', 'FANG', 'DLR', 'DFS', 'DISCA', 'DISCK', 'DISH', 'DG', 'DLTR', 'D', 'DOV', 'DOW', 'DTE', 'DUK', 'DRE', 'DD', 'DXC', 'ETFC', 'EMN', 'ETN', 'EBAY', 'ECL', 'EIX', 'EW', 'EA', 'EMR', 'ETR', 'EOG', 'EFX', 'EQIX', 'EQR', 'ESS', 'EL', 'EVRG', 'ES', 'RE', 'EXC', 'EXPE', 'EXPD', 'EXR', 'XOM', 'FFIV', 'FB', 'FAST', 'FRT', 'FDX', 'FIS', 'FITB', 'FE', 'FRC', 'FISV', 'FLT', 'FLIR', 'FLS', 'FMC', 'FL', 'F', 'FTNT', 'FTV', 'FBHS', 'FOXA', 'FOX', 'BEN', 'FCX', 'GPS', 'GRMN', 'IT', 'GD', 'GE', 'GIS', 'GM', 'GPC', 'GILD', 'GPN', 'GS', 'GWW', 'HAL', 'HBI', 'HOG', 'HRS', 'HIG', 'HAS', 'HCA', 'HCP', 'HP', 'HSIC', 'HSY', 'HES', 'HPE', 'HLT', 'HFC', 'HOLX', 'HD', 'HON', 'HRL', 'HST', 'HPQ', 'HUM', 'HBAN', 'HII', 'IDXX', 'INFO', 'ITW', 'ILMN', 'IR', 'INTC', 'ICE', 'IBM', 'INCY', 'IP', 'IPG', 'IFF', 'INTU', 'ISRG', 'IVZ', 'IPGP', 'IQV', 'IRM', 'JKHY', 'JEC', 'JBHT', 'JEF', 'SJM', 'JNJ', 'JCI', 'JPM', 'JNPR', 'KSU', 'K', 'KEY', 'KEYS', 'KMB', 'KIM', 'KMI', 'KLAC', 'KSS', 'KHC', 'KR', 'LB', 'LLL', 'LH', 'LRCX', 'LW', 'LEG', 'LEN', 'LLY', 'LNC', 'LIN', 'LKQ', 'LMT', 'L', 'LOW', 'LYB', 'MTB', 'MAC', 'M', 'MRO', 'MPC', 'MAR', 'MMC', 'MLM', 'MAS', 'MA', 'MKC', 'MXIM', 'MCD', 'MCK', 'MDT', 'MRK', 'MET', 'MTD', 'MGM', 'MCHP', 'MU', 'MSFT', 'MAA', 'MHK', 'TAP', 'MDLZ', 'MNST', 'MCO', 'MS', 'MOS', 'MSI', 'MSCI', 'MYL', 'NDAQ', 'NOV', 'NKTR', 'NTAP', 'NFLX', 'NWL', 'NEM', 'NWSA', 'NWS', 'NEE', 'NLSN', 'NKE', 'NI', 'NBL', 'JWN', 'NSC', 'NTRS', 'NOC', 'NCLH', 'NRG', 'NUE', 'NVDA', 'ORLY', 'OXY', 'OMC', 'OKE', 'ORCL', 'PCAR', 'PKG', 'PH', 'PAYX', 'PYPL', 'PNR', 'PBCT', 'PEP', 'PKI', 'PRGO', 'PFE', 'PM', 'PSX', 'PNW', 'PXD', 'PNC', 'PPG', 'PPL', 'PFG', 'PG', 'PGR', 'PLD', 'PRU', 'PEG', 'PSA', 'PHM', 'PVH', 'QRVO', 'PWR', 'QCOM', 'DGX', 'RL', 'RJF', 'RTN', 'O', 'RHT', 'REG', 'REGN', 'RF', 'RSG', 'RMD', 'RHI', 'ROK', 'ROL', 'ROP', 'ROST', 'RCL', 'CRM', 'SBAC', 'SLB', 'STX', 'SEE', 'SRE', 'SHW', 'SPG', 'SWKS', 'SLG', 'SNA', 'SO', 'LUV', 'SPGI', 'SWK', 'SBUX', 'STT', 'SYK', 'STI', 'SIVB', 'SYMC', 'SYF', 'SNPS', 'SYY', 'TROW', 'TTWO', 'TPR', 'TGT', 'TEL', 'FTI', 'TFX', 'TXN', 'TXT', 'TMO', 'TIF', 'TWTR', 'TJX', 'TMK', 'TSS', 'TSCO', 'TDG', 'TRV', 'TRIP', 'TSN', 'UDR', 'ULTA', 'USB', 'UAA', 'UA', 'UNP', 'UAL', 'UNH', 'UPS', 'URI', 'UTX', 'UHS', 'UNM', 'VFC', 'VLO', 'VAR', 'VTR', 'VRSN', 'VRSK', 'VZ', 'VRTX', 'VIAB', 'V', 'VNO', 'VMC', 'WAB', 'WMT', 'WBA', 'DIS', 'WM', 'WAT', 'WEC', 'WCG', 'WFC', 'WELL', 'WDC', 'WU', 'WRK', 'WY', 'WHR', 'WMB', 'WLTW', 'WYNN', 'XEL', 'XRX', 'XLNX', 'XYL', 'YUM', 'ZBH', 'ZION', 'ZTS']

  describe "Finds CUSIP for the S&P 500", vcr: { cassette_name: "schedule_13g_s&p" } do
    let(:uri) { 'https://www.sec.gov/Archives/edgar/data/80255/000008025517000887/sam13gdec16.txt' }

    let(:document) { described_class.fetch(uri) }

    it 'finds cusip' do
      skips = [
                'LLL', # not found in SEC web search
                'BHGE', # not found in SEC web search
                'HRS', # not found in SEC web search
                'TMK', # not found in SEC web search
                'BRK.B', # not found in SEC web search
                'BF.B', # not found in SEC web search
                'DIS', # no SC 13G or SC 13G/A
                'AMCR', # no SC 13G or SC 13G/A
                # 'BF.B', # not found in SEC web search
                # 'CTVA', # there is no `SC 13 G` filing
                # 'DIS', # there is no `SC 13 G` filing? really not one for DISNEY?
                # 'CELG', # cusip has a space in it `45166A 102`
                # 'GILD', # cusip has a space in it `43906K 100`
                # 'MRK', # cusip has a space in it `CUSIP   No.&nbsp;<b>&nbsp;</b>62921N&nbsp; 10&nbsp; 5</font>`
                # 'HSY', # cusip has a space in it `427866 10 8`
                # 'LLY', # cusip has a space in it `28414H 103`
                # 'PKI', # cusip present, just didn't find it
                # 'TFX', # cusip present, just didn't find it
                # 'DOW', # cusip has a space in it `717071 104` - has a `SC 13G/A` filing but not a `SC 13G`
                # 'RCL', # 13 G does not contain cusip, but `SC 13G/A` does
                # 'STX', # 13 G does not contain cusip, but `SC 13G/A` does (though might be hard to find)
                # 'INFO', # 13 G does not contain cusip, but `SC 13G/A` does
                # 'TEL', # 13 G does not contain cusip, but `SC 13G/A` does (easy)
                # 'WRK', # 13 G does not contain cusip, but `SC 13G/A` does (easy)
                # 'BLK' # 13 G does not contain cusip
      ]
      missing = []
      successful = []
      no_document = []
      S_P_500_TICKERS.each do |ticker|
        puts "Success count: #{successful.count}"
        puts "Current Ticker: #{ticker}"
        if skips.include?(ticker)
          puts "nope - skipping..."
          next
        end
        cik = SecQuery::Entity.find(ticker).cik
        schedule_13gs = SecQuery::Filing.find(cik, 0, 80, type: 'SC 13G')
        schedule_13ga = schedule_13gs&.find {|f| f.term == 'SC 13G/A' && f&.detail&.subject&.cik == cik }
        schedule_13g  = schedule_13gs&.find {|f| f.term == 'SC 13G'  && f&.detail&.subject&.cik == cik }

        cusip = schedule_13g&.document&.cusip || schedule_13ga&.document&.cusip || ''

        if cusip.match /[0-9A-Z]{9}|[0-9A-Z]{8}|[0-9A-Z]{7}/
          successful << [ticker, cusip]
        elsif cusip.match /[0-9A-Z]{9}|[0-9A-Z]{8}|[0-9A-Z]{7}/ #TODO pull this one out and see how many are dropped
          successful << [ticker, schedule_13ga&.document&.cusip]
        elsif cusip.match /^[0-9A-Z]{6}\s[0-9A-Z]{3}$/
          successful << [ticker, cusip]
        elsif cusip.match(/^[0-9A-Z]{6}$/) || schedule_13g&.document&.cusip&.match(/^[0-9A-Z]{7}$/) || schedule_13g&.document&.cusip&.match(/^[0-9A-Z]{8}$/) || schedule_13g&.document&.cusip&.match(/^[0-9A-Z]{9}$/)
          successful << [ticker, cusip]
        elsif cusip.match /^[0-9A-Z]{6}\s[0-9A-Z]{2}\s[0-9A-Z]{1}$/
          successful << [ticker, cusip]
        elsif cusip.match /^[0-9A-Z]{6}\s\s[0-9A-Z]{2}\s\s[0-9A-Z]{1}$/
          successful << [ticker, cusip]
        elsif cusip.match /^[0-9A-Z]{6}[-]{1}[0-9A-Z]{2}[-]{1}[0-9A-Z]{1}$/
          successful << [ticker, cusip]
        elsif !schedule_13g&.document && !schedule_13ga&.document
          no_document << [ticker, cusip]
        else
          puts "cusip ::: #{schedule_13g&.document&.cusip&.strip}"
          missing << [ticker, schedule_13g&.document&.cusip, schedule_13g&.document&.parser&.link]
        end
      end
      puts "Found #{successful.count}"
      # puts successful.each {|ticker, schedule_13g| ticker}.join(',')
      # successful.count -> 395
      # missing.count -> 104
      #
      # No Document 3
      # Found 502
      # Missing 0
      #
      expect(missing.count).to eq 0
      expect(successful.count).to eq 502
    end
  end
end
