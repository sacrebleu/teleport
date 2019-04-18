class HealthController < ApplicationController
  def get_cluster_health
    begin
      res = limit(Stats::Health.fetch(params[:number]))

      render plain: res, status: 200
    rescue Stats::RateLimited
      render plain: { status: :error, message: "Rate limited by server" }
    end
  end

  def sanity_check
    begin
      res = limit(Stats::Health.sanity(params[:number]))

      output = <<~EOF
# HELP liveness check for whatsapp cluster for customer number #{params[:number]}
# TYPE whatsapp_cluster_health gauge
whatsapp_cluster_health{customer="#{params[:number]}"} #{res}
      EOF

      render plain: output, status: 200
    rescue Stats::RateLimited
      render plain: { status: :error, message: "Rate limited by server" }
    end
  end
end
