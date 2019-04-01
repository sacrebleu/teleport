module Stats
  class Authenticator

    # cache the authorization token for reuse
    def self.authorize(number)
      if Rails.cache.fetch("ratelimits/#{number}")
        Rails.logger.warn "Rate limited for #{number}"
        return nil
      end
      token = session_token(number)
      "Bearer #{token}"
    end

    # authenticate against the remote server and retrieve a token
    def self.authenticate(number)
      Rails.logger.info "Authenticating with remote server"
      lookup = lookup_number(number)

      creds = Credential.where(country: lookup.country, phone: lookup.phone).first

      begin
        HttpApi.authenticate(number, creds.username, creds.password)
      rescue RestClient::TooManyRequests
        Rails.logger.info "Auth requests for #{number} are rate limited."
        Rails.cache.write("ratelimits/#{number}", true, :expires_in => 1.minutes)
        raise RateLimited.new("429 Too Many Requests")
      end
    end

    # fetch the number's token, or authenticate via basic auth and generate a new token if no token is found
    def self.session_token(number)
      Rails.cache.fetch("tokens/#{number}", :expires_in => 24.hours) do
        authenticate(number)
      end
    end

    def self.lookup_number(number)
      l = Lookup.find_by_number(number)

      unless l
        populate_lookups
        l = Lookup.find_by_number(number)

        raise "No such number in the configuration database: #{number}" unless l
      end
      l
    end

    def self.populate_lookups
      res = ActiveRecord::Base.connection.execute(<<~EOF
  SELECT wa.country, wa.phone
  FROM   whatsapp_config wa
  LEFT OUTER JOIN lookups
  ON (wa.phone = lookups.phone)
  WHERE lookups.phone IS NULL
      EOF
      )

      res.each do |record|
        Lookup.create!(country: record[0], phone: record[1], number: "#{record[0]}#{record[1]}")
      end

      Rails.logger.info "Populated lookups table with #{res.count} missing records"
    end
  end
end
