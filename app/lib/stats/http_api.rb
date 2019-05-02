# frozen_string_literal: true

module Stats
  # facade onto RestClient that wraps functionality like bearer authentication
  # and honours backoffs and ratelimiting rules
  class HttpApi
    def self.authenticate(number, username, password)
      code, auth_res = HttpApi.post(WhatsappUrl.generate(number, '/users/login'),
                                    basic_auth(username, password))

      if code == :ok
        token = auth_res[:body]['users'].first['token']
      else
        Rails.logger.info "Auth failure for #{number}, backing off."
        Rails.cache.write("authfail/#{number}", true, expires_in: 1.minutes)
        raise Unauthenticated.new, "Auth failure for #{number}, backing off."
      end

      token
    end

    def self.basic_auth(username, password)
      hash = Base64.encode64("#{username}:#{password}")
      "Basic #{hash}"
    end

    def self.post(url, auth_header, opts = { expects: 200, format: :json })
      execute url, :post, auth_header, opts
    end

    def self.get(url, auth_header, opts = { expects: 200, format: :json })
      execute url, :get, auth_header, opts
    end

    def self.execute(url, method, auth_header, opts = { expects: 200, format: :json })
      res = call(url, method, auth_header)
      body = res.body
      if res.code == (opts[:expects] || 200).to_i
        [:ok, { code: res.code, body: opts[:format] == :raw ? body : JSON.parse(body) }]
      else
        [:error, { code: res.code, body: JSON.parse(body) }]
      end
    rescue RestClient::Unauthorized
      [:error, { code: 401, body: 'Unauthorized' }]
    end

    def self.call(url, method, auth_header)
      RestClient::Request.execute(
        url: url,
        method: method,
        headers: { accept: 'application/json', 'Authorization' => auth_header },
        verify_ssl: false
      )
    end
  end
end
