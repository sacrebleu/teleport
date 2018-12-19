class MetricsController < ApplicationController
  
  def get_cluster_metrics

  	res, code = Metrics.fetch(params[:number])
  	
  	render plain: res, status: code
  end

end
