# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HealthController, type: :controller do
  render_views

  let(:test_mo) { 441_234_567_890 }

  let(:health_response_unregistered) do
    '{ "health": { "10.212.65.151:wa-master-441234567890-0": {"gateway_status": "unregistered", "role": "primary_master" },
                   "10.212.65.151:wa-core-441234567890-1": { "errors":[{"title": "Service not ready", "code": 1011, "details": "Wacore is not instantiated. Please check wacore log for details."}]}}}'
  end

  let(:health_response_connected) do
    '{ "health": { "10.212.65.151:wa-master-441234567890-0": {"gateway_status": "connected", "role": "primary_master" }}}'
  end

  let(:health_response_single_node) do
    '{ "health": {"10.210.71.117:wa-master-447418342132-0":{"gateway_status":"disconnected","role":"primary_master"},"10.210.72.103:wa-core-447418342132-0":{"gateway_status":"connected","role":"coreapp"}}}'
  end

  let(:unhealthy_struct) do
    JSON.parse(health_response_unregistered)['health']
  end

  let(:unhealthy_aggregate) do
    { '441234567890' => [['wa-master-441234567890-0', 'unregistered']] }
  end

  let(:gauge_response_healthy) do
    <<~ENDDOC
      # HELP liveness check for whatsapp cluster for customer number 441234567890
      # TYPE whatsapp_cluster_health gauge
      whatsapp_cluster_health{customer="441234567890",customer_name="Test company"} 1
    ENDDOC
  end

  let(:gauge_response_unhealthy) do
    <<~ENDDOC
      # HELP liveness check for whatsapp cluster for customer number 441234567890
      # TYPE whatsapp_cluster_health gauge
      whatsapp_cluster_health{customer="441234567890",customer_name="Test company"} 0
    ENDDOC
  end

  describe 'GET #index' do
    it 'generates a JSON map of cluster failures for the json mime type' do
      expect(Rails.cache).to receive(:fetch).with("health/#{test_mo}").and_return(unhealthy_struct)

      get :index, format: :json

      expected = [
        ['441234567890', 'wa-master-441234567890-0', 'unregistered'],
        ['441234567890', 'wa-core-441234567890-1', 'Service not ready (1011) - Wacore is not instantiated. Please check wacore log for details.']
      ]

      expect(response.content_type).to eq('application/json')

      expect(JSON.parse(response.body)).to eql(expected)
    end

    it 'generates a HTML response by default' do
      expect(Rails.cache).to receive(:fetch).with("health/#{test_mo}").and_return(unhealthy_struct)

      get :index, format: :html

      expect(response.content_type).to eq('text/html')
    end
  end

  describe 'GET #get_cluster_health' do
    it 'returns a rate limited response if the service is rate limiting teleport' do
      expect(Stats::Authenticator).to receive(:ratelimited?).with(test_mo.to_s).and_return(true)

      get :cluster_health, params: { number: test_mo }
      expect(response.code).to eql('429')
    end

    it 'returns a back off response if the service is in authentication backoff' do
      expect(Stats::Authenticator).to receive(:ratelimited?).with(test_mo.to_s).and_return(false)
      expect(Stats::Authenticator).to receive(:backoff?).with(test_mo.to_s).and_return(true)

      get :cluster_health, params: { number: test_mo }
      expect(response.code).to eql('401')
    end

    it 'returns http 200 for a valid request' do
      expect(Stats::Health).to receive(:authorize).with(test_mo.to_s).and_return([{}, 200])
      expect(Stats::HttpApi).to receive(:get).with("https://#{test_mo}.wa.nexmo.cloud:443/v1/health", {}, format: :raw).and_return(
        [:ok, body: health_response_connected]
      )

      get :cluster_health, params: { number: test_mo }
      expect(response).to be_successful
    end
  end

  describe 'GET #sanity_check' do
    it 'returns a prometheus data gauge with value 1 for a successful cluster health check' do
      expect(Stats::Health).to receive(:authorize).with(test_mo.to_s).and_return([{}, 200])
      expect(Stats::HttpApi).to receive(:get).with("https://#{test_mo}.wa.nexmo.cloud:443/v1/health", {}, format: :raw).and_return(
        [:ok, { body: health_response_connected }]
      )

      get :cluster_status, params: { number: test_mo }
      expect(response).to be_successful

      expect(response.body).to eql(gauge_response_healthy)
    end

    it 'returns a prometheus data gauge with value 1 for a failed cluster health check' do
      expect(Stats::Health).to receive(:authorize).with(test_mo.to_s).and_return([{}, 200])
      expect(Stats::HttpApi).to receive(:get).with("https://#{test_mo}.wa.nexmo.cloud:443/v1/health", {}, format: :raw).and_return(
        [:ok, { body: health_response_unregistered }]
      )

      get :cluster_status, params: { number: test_mo }
      expect(response).to be_successful

      expect(response.body).to eql(gauge_response_unhealthy)
    end
  end
end
