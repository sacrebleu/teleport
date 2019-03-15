class ApplicationController < ActionController::Base
	rescue_from Stats::Unauthenticated, with: :unauthenticated

  def unauthenticated
  	render json: { message: "Unable to authenticate to whatsapp cluster, verify credentials are correct and update if required." }, status: :unauthorized
  end

end
