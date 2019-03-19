class MetricsController < ApplicationController

  def index
    res, _ = Stats::Metrics.fetch(params[:number])

    s = Stats::Status.new(params[:number], res)

    @rows = s.metrics
  end

  def get_cluster_metrics

  	res, code = Stats::Metrics.fetch(params[:number])

  	render plain: res, status: code
  end

end
