class Authenticator

	# cache the authorization token for reuse
	def self.authorize(number)
		token = session_token(number)
		"Bearer #{token}"
	end

  # authenticate against the remote server and retrieve a token
	def self.authenticate(number)
		Rails.logger.info "Authenticating with remote server"
		lookup = Lookup.find_by_mo(number)

  	creds = Credential.where(country: lookup.cc, phone: lookup.number).first

  	code, auth_res = HttpApi.post(
  		"https://api.#{lookup.mo}.wa.prod.nexmo.cloud:443/v1/users/login",
  		basic_auth(creds.username, creds.password)
  	)

  	if code == :ok
  		token = auth_res["users"].first["token"]
  	else
  		Rails.logger.error auth_res
  		raise Unauthenticated.new
  	end

  	token
  end

  def self.basic_auth(username, password)
  	hash = Base64::encode64("#{username}:#{password}")
  	"Basic #{hash}"
  end

  # fetch the number's token, or authenticate via basic auth and generate a new token if no token is found
  def self.session_token(number)
		Rails.cache.fetch("tokens/#{number}", :expires_in => 24.hours) do
	    authenticate(number)
	  end
  end
end

