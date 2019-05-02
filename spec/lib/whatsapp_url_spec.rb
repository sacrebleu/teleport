# frozen_string_literal: true

describe 'WhatsappUrl' do
  let(:subject) { WhatsappUrl }

  it 'generates an endpoint for the api for the required number' do
    subject.generate('123', '/foo').should eql('https://123.wa.nexmo.cloud:443/v1/foo')
  end

  it 'generates a metrics endpoint for the required number' do
    subject.metrics('123', '/metrics').should eql('https://123.wa.nexmo.cloud:443/metrics')
  end
end
