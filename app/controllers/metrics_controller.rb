class MetricsController < ApplicationController

  def index
    res, = Stats::Metrics.fetch(params[:number])

    s = Stats::Status.new(params[:number], res)

    @rows = s.metrics
  end

  def get_cluster_metrics
    begin
      res = limit(Stats::Metrics.fetch(params[:number]))
      res << limit(Stats::Stats.core_stats(params[:number]))
      res << limit(Stats::Stats.db_stats(params[:number]))

      customer_name = Stats::Customer.fetch_company_name(params[:number])

      health = <<~EOF
# HELP liveness check for whatsapp cluster for customer number #{params[:number]}
# TYPE whatsapp_cluster_health gauge
whatsapp_cluster_health{customer="#{params[:number]}",customer_name="#{customer_name}"} #{limit(Stats::Health.sanity(params[:number]))}
      EOF

      res << health

      render plain: res, status: 200
    rescue Stats::RateLimited
      render plain: { status: :error, message: "Rate limited by server" }
    end
  end

  def get_core_stats
    res, code = Stats::Stats.core_stats(params[:number])

    render plain: res, status: code
  end

  def get_db_stats
    res, code = Stats::Stats.db_stats(params[:number])

    render plain: res, status: code
  end

end
