# permit external setting of credentials for authentication onto whatsapp clusters for stat retrieval
class CredentialsController < ApplicationController
 	
  def set_credentials
  	c = Credential.find_by_number(params[:number])

  	if c.nil?
  		c = Credential.new(number: params[:number], username: params[:username], password: params[:password])
  	else
  		c.password = params[:password]
  	end
  	c.save!

  	Rails.logger.info "Flushing existing tokens for cluster #{params[:number]}"
  	Rails.cache.delete("tokens/#{params[:number]}")

  	render json: { }, status: :ok
  end


end
