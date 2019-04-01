class MetricsController < ApplicationController

  def index
    res, _ = Stats::Metrics.fetch(params[:number])

    s = Stats::Status.new(params[:number], res)

    @rows = s.metrics
  end

  def get_cluster_metrics
    begin
      r1, c1 = Stats::Metrics.fetch(params[:number])
      raise Stats::RateLimited.new if c1 == 429
      r2, c2 = Stats::Stats.core_stats(params[:number])
      raise Stats::RateLimited.new if c2 == 429
      r3, c3 = Stats::Stats.db_stats(params[:number])
      raise Stats::RateLimited.new if c3 == 429

      render plain: r1 << r2 << r3, status: [c1, c2, c3].max
    rescue Stats::RateLimited => e
      render plain: { status: :error, message: "Rate limited" }
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
