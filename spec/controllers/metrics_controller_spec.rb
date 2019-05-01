# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MetricsController, type: :controller do
  let(:test_mo) { '441234567890' }

  let(:res) do
    <<~GAUGE
      # HELP liveness check for whatsapp cluster for customer number #{test_mo}
      # TYPE whatsapp_cluster_health gauge
      whatsapp_cluster_health{customer="#{test_mo}",customer_name="Test company"} 1
    GAUGE
  end

  describe 'GET display' do
    it 'returns http success' do
      Rails.cache.clear

      expect(Stats::Metrics).to receive(:authorize).with(test_mo.to_s).and_return([{}, 200])

      expect(Stats::HttpApi).to receive(:get).with("https://#{test_mo}.wa.nexmo.cloud:443/metrics?format=prometheus", {}, format: :raw).and_return(
        [:ok, '']
      )

      # expect(Stats::Health).to receive(:sanity).with(test_mo).and_return(1)

      get :display, params: { number: test_mo }, format: :text
      expect(response).to be_successful
    end
  end

  describe 'GET fetch' do
    it 'returns http success' do
      expect(Stats::Metrics).to receive(:authorize).with(test_mo.to_s).and_return([{}, 200])
      expect(Stats::Stats).to receive(:authorize).twice.with(test_mo.to_s).and_return([{}, 200])

      expect(Stats::HttpApi).to receive(:get).with("https://#{test_mo}.wa.nexmo.cloud:443/metrics?format=prometheus", {}, format: :raw).and_return(
        [:ok, '']
      )

      expect(Stats::HttpApi).to receive(:get).with("https://#{test_mo}.wa.nexmo.cloud:443/v1/stats/app?format=prometheus", {}, format: :raw).and_return(
        [:ok, '']
      )

      expect(Stats::HttpApi).to receive(:get).with("https://#{test_mo}.wa.nexmo.cloud:443/v1/stats/db?format=prometheus", {}, format: :raw).and_return(
        [:ok, '']
      )

      expect(Stats::Health).to receive(:sanity).with(test_mo).and_return(1)

      get :fetch, params: { number: test_mo }, format: :text
      expect(response).to be_successful
      expect(response.body).to eql(res)
    end
  end
end
