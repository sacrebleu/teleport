class MetricsController < ApplicationController

  def index
    res, _ = Stats::Metrics.fetch(params[:number])

    s = Stats::Status.new(params[:number], res)

    @rows = s.metrics
  end

  def get_cluster_metrics

  	r1, c1 = Stats::Metrics.fetch(params[:number])
    r2, c2 = Stats::Stats.core_stats(params[:number])
    r3, c3 = Stats::Stats.db_stats(params[:number])

  	render plain: r1 << r2 << r3, status: [c1, c2, c3].max
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
