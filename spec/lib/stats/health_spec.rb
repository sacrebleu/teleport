# frozen_string_literal: true

describe 'Stats::Health' do
  let(:subject) { Stats::Health }

  let(:health_response_unregistered) do
    '{ "health": { "10.212.65.151:wa-master-441234567890-0": {"gateway_status": "unregistered", "role": "primary_master" },
                   "10.212.65.151:wa-core-441234567890-1": { "errors":[{"title": "Service not ready", "code": 1011, "details": "Wacore is not instantiated. Please check wacore log for details."}]}}}'
  end

  let(:health_response_disconnected) do
    '{ "health": { "10.212.65.151:wa-core-441234567890-1": { "gateway_status": "disconnected"} } }'
  end

  let(:health_response_connected) do
    '{ "health": { "10.212.65.151:wa-core-441234567890-1": { "gateway_status": "connected"} } }'
  end

  let(:test_mo) { '441234567890' }
  let(:token) { 'test_token' }
  let(:url) { WhatsappUrl.generate(test_mo, '/health') }

  let(:unhealthy_struct) do
    JSON.parse(health_response_unregistered)['health']
  end

  context 'in aggregation' do
    it 'generates a status map from a json struct' do
      expect(Rails.cache).to receive(:fetch).with("health/#{test_mo}").and_return(unhealthy_struct)

      expected = [
          ['441234567890', 'wa-master-441234567890-0', 'unregistered'],
          ['441234567890', 'wa-core-441234567890-1',
           'Service not ready (1011) - Wacore is not instantiated. Please check wacore log for details.']
          ]

      expect(subject.aggregate).to eql(expected)
    end

    it 'collates error lists into meaningful text' do
      struct = [
        {
          'title' => 'T1',
          'code' => 'C1',
          'details' => 'D1'
        },
        {
          'title' => 'T2',
          'code' => 'C2',
          'details' => 'D2'
        }
      ]

      expect(subject.collate_errors(struct)).to eql('T1 (C1) - D1, T2 (C2) - D2')
    end
  end

  context 'in fetch' do
    it 'fetches the health for a whatsapp cluster by mo' do
      expect(subject).to receive(:authorize).with(test_mo).and_return(["Bearer #{token}", 200])
      expect(Stats::HttpApi).to receive(:get).with(url, "Bearer #{token}", format: :raw).and_return(
        [:ok, health_response_unregistered]
      )

      res, code = subject.fetch(test_mo)
      expect(code).to eql(200)
      expect(res['10.212.65.151:wa-master-441234567890-0']['gateway_status']).to eql('unregistered')
    end
  end

  context 'in sanity' do
    it 'fetches and calculates the liveness of a healthy cluster as alive' do
      expect(subject).to receive(:authorize).with(test_mo).and_return(["Bearer #{token}", 200])
      expect(Stats::HttpApi).to receive(:get).with(url, "Bearer #{token}", format: :raw).and_return(
        [:ok, { body: health_response_connected }]
      )

      res, code = subject.sanity(test_mo)
      expect(code).to eql(200)
      expect(res).to eql(1)
    end

    it 'reports a cluster with at least one disconnected node as unhealthy' do
      expect(subject).to receive(:authorize).with(test_mo).and_return(["Bearer #{token}", 200])
      expect(Stats::HttpApi).to receive(:get).with(url, "Bearer #{token}", format: :raw).and_return(
        [:ok, {body: health_response_disconnected}]
      )

      res, code = subject.sanity(test_mo)
      expect(code).to eql(200)
      expect(res).to eql(0)
    end
  end
end
