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

      customer_name = Stats::Customer.fetch_company_name(params[:number])

      output = <<~EOF
# HELP liveness check for whatsapp cluster for customer number #{params[:number]}
# TYPE whatsapp_cluster_health gauge
whatsapp_cluster_health{customer="#{params[:number]}",name="#{customer_name}"} #{res}
      EOF

      render plain: output, status: 200
    rescue Stats::RateLimited
      render plain: { status: :error, message: "Rate limited by server" }
    end
  end
end
