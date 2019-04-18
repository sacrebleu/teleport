class ApplicationController < ActionController::Base
	rescue_from Stats::Unauthenticated, with: :unauthenticated

  def unauthenticated
  	render json: { message: "Unable to authenticate to whatsapp cluster, verify credentials are correct and update if required." }, status: :unauthorized
  end

  def limit(result)
    raise Stats::RateLimited, 'Rate limited by server' if result[1] == 429

    result[0]
  end

end
