# frozen_string_literal: true

# base controller for application
class ApplicationController < ActionController::Base
  rescue_from Stats::Unauthenticated, with: :unauthenticated
  rescue_from Stats::RateLimited, with: :ratelimited

  def unauthenticated
    render json: {
      message: 'Unable to authenticate to whatsapp cluster, verify credentials are correct and update if required.'
    }, status: :unauthorized
  end

  def ratelimited
    render json: { message: 'Rate limited by server' }, status: :too_many_requests
  end
end
