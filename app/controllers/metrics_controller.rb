# frozen_string_literal: true

# controller class for handling requests to metrics endpoints for whatsapp MOs
class MetricsController < ApplicationController
  def display
    res, = Stats::Metrics.fetch(params[:number])

    s = Stats::Status.new(params[:number], res)

    @rows = s.metrics
  end

  def fetch
    res = limit(Stats::Metrics.fetch(params[:number]))
    res << limit(Stats::Stats.core_stats(params[:number]))
    res << limit(Stats::Stats.db_stats(params[:number]))

    customer_name = Stats::Customer.fetch_company_name(params[:number])

    health = <<~GAUGE
      # HELP liveness check for whatsapp cluster for customer number #{params[:number]}
      # TYPE whatsapp_cluster_health gauge
      whatsapp_cluster_health{customer="#{params[:number]}",customer_name="#{customer_name}"} #{limit(Stats::Health.sanity(params[:number]))}
    GAUGE

    res << health

    render plain: res, status: 200
  rescue Stats::RateLimited
    render plain: { status: :error, message: 'Rate limited by server' }
  end
end
