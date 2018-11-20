class Authenticator

	# cache the authorization token for reuse
	def self.authorize(number)
		token = session_token(number)
		"Bearer #{token}"
	end

  # authenticate against the remote server and retrieve a token
	def self.authenticate(number)
		Rails.logger.info "Authenticating with remote server"
  	creds = Credential.find_by_number(number)

  	# need error handling here
  	code, auth_res = HttpApi.post(
  		"https://api.#{creds.number}.wa.prod.nexmo.cloud:443/v1/users/login",
  		basic_auth(creds.username, creds.password)
  	)

  	# Rails.logger.info code
  	# Rails.logger.info auth_res

  	if code == :ok
  		token = auth_res["users"].first["token"]
  	else
  		Rails.logger.error auth_res
  		raise Unauthenticated.new
  	end
  	# Rails.logger.debug token

  	token
  end

  def self.basic_auth(username, password)
  	hash = Base64::encode64("#{username}:#{password}")
  	"Basic #{hash}"
  end

  # fetch the number's token, or authenticate via basic auth and generate a new token if no token is found
  def self.session_token(number)
		Rails.cache.fetch("tokens/#{number}", :expires_in => 1.minutes) do
	    authenticate(number)
	  end
  end
end

# RestClient::Request.execute(:url => 'https://selfsigned.ssltest.me', :method => :get, :verify_ssl => false)