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

      render plain: res, status: 200
    rescue Stats::RateLimited
      render plain: { status: :error, message: "Rate limited by server" }
    end
  end

  def limit(result)
    raise Stats::RateLimited, 'Rate limited by server' if result[1] == 429

    result[0]
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
