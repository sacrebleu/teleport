# frozen_string_literal: true

# controller class for handling requests to metrics endpoints for whatsapp MOs
class MetricsController < ApplicationController
  respond_to :html, :json

  def display
    res, = Stats::Metrics.fetch(params[:number])

    s = Stats::Status.new(params[:number], res)

    @rows = s.metrics
  end

  def fetch
    number = params[:number]
    customer_name = Stats::Customer.fetch_company_name(number)

    res = <<~GAUGE
      #{build_metrics(number)}
      # HELP liveness check for whatsapp cluster for customer number #{number}
      # TYPE whatsapp_cluster_health gauge
      whatsapp_cluster_health{customer="#{number}",customer_name="#{customer_name}"} #{Stats::Health.sanity(number)}
    GAUGE

    render plain: res, status: 200
  rescue Stats::RateLimited
    render plain: { status: :error, message: 'Rate limited by server' }
  end

  def build_metrics(number)
    res = Stats::Metrics.fetch(number)[0].dup
    res << Stats::Stats.core_stats(number)[0]
    res << Stats::Stats.db_stats(number)[0]
  end
end
