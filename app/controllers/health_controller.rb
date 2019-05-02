# frozen_string_literal: true

# controller governing cluster health check routes
class HealthController < ApplicationController
  respond_to :html, :json

  def index
    @rows = Stats::Health.aggregate

    respond_to do |format|
      format.html { respond_with(@rows) }
      format.json { render json: @rows }
    end
  end

  def cluster_health
    render plain: Stats::Health.fetch(params[:number])
  end

  def cluster_status
    res = Stats::Health.sanity(params[:number])

    customer_name = Stats::Customer.fetch_company_name(params[:number]) || 'None'

    output = <<~GAUGE
      # HELP liveness check for whatsapp cluster for customer number #{params[:number]}
      # TYPE whatsapp_cluster_health gauge
      whatsapp_cluster_health{customer="#{params[:number]}",customer_name="#{customer_name}"} #{res[0]}
    GAUGE

    render plain: output
  end
end
