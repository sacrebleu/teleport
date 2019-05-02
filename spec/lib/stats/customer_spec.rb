# frozen_string_literal: true

describe 'Stats::Customer' do
  let(:subject) { Stats::Customer }
  let(:test_mo) { '441234567890' }

  it 'fetches a customer name' do
    Rails.cache.clear
    expect(subject.fetch_company_name(test_mo)).to eql('Test company')
  end
end
