module Stats
  class HttpApi

    def self.authenticate(number, username, password)
      code, auth_res = HttpApi.post(WhatsappUrl.generate(number, "/users/login"),
                                    basic_auth(username, password)
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

    def self.post url, auth_header, opts = {expects: 200, format: :json}
      execute url, :post, auth_header, opts
    end

    def self.get url, auth_header, opts = {expects: 200, format: :json}
      execute url, :get, auth_header, opts
    end

    def self.execute url, method, auth_header, opts = {expects: 200, format: :json }
      # Rails.logger.info "Calling #{method}: #{url}"
      # Rails.logger.info "auth: #{auth_header}"
      begin
        res = RestClient::Request.execute(
            url: url,
            method: method,
            headers: {accept: "application/json", "Authorization" => auth_header},
            verify_ssl: false)

        # HTTP OK
        if res.code == (opts[:expects] || 200).to_i
          if opts[:format] == :raw
            [:ok, res.body]
          else
            [:ok, JSON.parse(res.body)]
          end
        else
          [:error, {code: res.code, body: JSON.parse(res.body)}]
        end
      rescue RestClient::Unauthorized
        [:error, {code: 401, body: "Unauthorized"}]
      end


    end
  end
end