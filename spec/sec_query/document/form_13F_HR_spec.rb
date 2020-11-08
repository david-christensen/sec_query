# encoding: utf-8
include SecQuery
require 'spec_helper'
require 'byebug'

describe SecQuery::Document::Form13F_HR, vcr: { cassette_name: 'form_13f_hr' } do
  let(:cik) { '0001067983' }
  let(:filing) { SecQuery::Filing.find(cik, 0, 1, {type: '13F-HR'}).first }

  let(:uri) { 'https://www.sec.gov/Archives/edgar/data/320193/000032019318000137/wf-form4_153877878310747.xml' }
  subject(:document) { filing.document }

  it 'serializes with .to_h' do
    expect(document.to_h.keys).to eq %w[type period_of_report filer_cik filer_info form table]
    expect(document.to_h['filer_info'].keys).to eq %w[live_test_flag flags filer]
    expect(document.to_h['form'].keys).to eq %w[cover_page signature_block summary_page]
    expect(document.to_h['table'].any?).to eq true
    expect(document.to_h['table'].first.keys).to eq %w[name_of_issuer title_of_class cusip value other_manager shrs_or_prn_amt voting_authority]
  end
end
