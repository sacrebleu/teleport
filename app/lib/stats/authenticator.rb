# frozen_string_literal: true

module Stats
  # facade onto whatsapp's authentication / authorization scheme.  Generates bearer tokens,
  # authenticates, honours backoff and rate limiting
  class Authenticator
    # check to see whether a ratelimiting rule is active for this number
    def self.ratelimited?(number)
      Rails.cache.fetch("ratelimits/#{number}") && Rails.logger.warn("Rate limited for #{number}")
    end

    # check to see whether a backoff rule is active for this number
    def self.backoff?(number)
      Rails.cache.fetch("authfail/#{number}") && Rails.logger.warn('Auth failed, in backoff period.')
    end

    # Authorise a request, honouring backoff or ratelimiting rules
    def self.authorize(number)
      raise RateLimited.new, "Rate limited for #{number}." if ratelimited?(number)
      raise Unauthenticated.new, "Auth failed, in backoff period for #{number}." if backoff?(number)

      token = session_token(number)
      ["Bearer #{token}", 200]
    end

    # authenticate against the remote server and retrieve a token
    def self.authenticate(number)
      Rails.logger.info 'Authenticating with remote server'
      lookup = lookup_number(number)

      creds = Credential.where(country: lookup.country, phone: lookup.phone).first

      raise Unauthenticated.new, "#{number} - No valid username in database" unless creds.username
      raise Unauthenticated.new, "#{number} - No valid password in database" unless creds.password

      do_auth number, creds
    end

    def self.do_auth(number, creds)
      HttpApi.authenticate(number, creds.username, creds.password)
    rescue RestClient::TooManyRequests
      Rails.logger.info "Auth requests for #{number} are rate limited."
      Rails.cache.write("ratelimits/#{number}", true, expires_in: 1.minutes)
      raise RateLimited.new, "429 Too Many Requests for #{number}"
    end

    # fetch the number's token, or authenticate via basic auth and generate a
    # new token if no token is found
    def self.session_token(number)
      Rails.cache.fetch("tokens/#{number}", expires_in: 24.hours) { authenticate(number) }
    end

    # use the Customer facade to resolve the number to a credential
    def self.lookup_number(number)
      Customer.lookup_number(number)
    end
  end
end
