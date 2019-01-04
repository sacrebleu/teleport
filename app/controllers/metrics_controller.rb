class MetricsController < ApplicationController

  def index
    res, _ = Metrics.fetch(params[:number])

    s = Status.new(params[:number], res)

    @rows = s.metrics
  end

  def get_cluster_metrics

  	res, code = Metrics.fetch(params[:number])
  	
  	render plain: res, status: code
  end

end
