module Cluster
  class Api

    # PREFIX="https://api."
    # SUFFIX=".wa.prod.nexmo.cloud:443/v1"

    HEADERS = {expects: 200, format: :json}

    # issue an auth request against a whatsapp cluster
    def self.authenticate(mo_number, basic_auth)
      code, res = HttpHelper.post url(mo_number, "/users/login"), nil, HEADERS.merge(authorization: basic_auth)

      if code == :ok
        puts "Passed".green
        res["users"].first["token"]
      else
        puts "Failed".red
        raise "Could not authenticate"
      end
    end

    # update auth credentials for a whatsapp cluster
    def self.update_credentials(session, basic_auth, new_password)

      body = {
          "new_password": new_password
      }

      code, res = HttpHelper.post url(mo_number, "/users/login"), nil, HEADERS.merge(payload: body, authorization: basic_auth)

      if code == :ok
        puts "Passed".green
        auth_res["users"].first["token"]
      else
        puts "Failed".red
        raise "Could not set new password on cluster #{session.number}"
      end
    end

    # returns 201 created if the account was new, 202 Accepted if the account exists already
    def self.initialise_2fa(session, cc, number, method, cert, pin)
      body = {
          "cc": cc,
          "phone_number": session.number.delete_prefix(cc),
          "method": method,
          "cert": cert,
          "pin": pin
      }
      code, res = HttpHelper.post(url(session.number, "/account"), session, HEADERS.merge(payload: body, expects: [201, 202]))

      if :ok != code
        puts res.inspect
        raise "Could not initiate 2fa token request on cluster #{session.number}"
      else
        return [:ok, {}]
      end
    end

    def self.set_webhook(session)
      body = {
          "webhooks": {"url": "https://messages.nexmo.com/chatapp/mo/whatsapp/#{session.number}"}
      }

      code, res = HttpHelper.patch(url(session.number, "/settings/application"), session, HEADERS.merge(payload: body, expects: [200, 201, 202]))

      puts code

      if :ok != code
        puts res.inspect
        raise "Could not initiate 2fa token request on cluster #{session.number}"
      else
        return [:ok, {}]
      end
    end


    def self.verify_2fa_token(session, token)
      code, res = HttpHelper.post(url(session.number, "/account/verify"), session, HEADERS.merge(payload: {code: token}, expects: 201))

      if :ok != code
        puts res.inspect
        raise "Could not verify 2fa token on cluster #{session.number}."
      else
        return [:ok, {}]
      end
    end

    def self.set_shard_count(session, count, cc, pin)
      body = {
          "cc": cc,
          "phone_number": number.delete_prefix(session.number),
          "shards": count,
          "pin": pin
      }

      code, res = HttpHelper.post(url(session.number, "/account/shards"), session, HEADERS.merge(payload: body, expects: 201))

      if :ok != code
        puts res.inspect
        raise "Could not update shard count on cluster #{session.number}."
      else
        return [:ok, {}]
      end

    end

    def self.send_test_message(session, mt_number)
      body = {
          "to": mt_number.to_s,
          "type": "hsm",
          "hsm": {
              "namespace": "whatsapp:hsm:technology:nexmo",
              "element_name": "verify",
              "language": {
                  "policy": "fallback",
                  "code": "en_US"
              },
              "localizable_params": [
                  {"default": "10"},
                  {"default": "1234"},
                  {"default": "1234"}
              ]
          }
      }

      code, res = HttpHelper.post(url(session.number, "/messages"), session, HEADERS.merge(payload: body, expects: 201))

      if :ok != code
        puts res.inspect
        raise "Could not deliver MT via cluster #{session.number}."
      else
        return [:ok, res["messages"].first["id"]]
      end
    end

    def self.url(number, path)
      Url.generate(number, path)
      # "#{config.x.api_endpoint.gsub("MO", number).gsub("ENV.", config.x.env)}#{path}"

      # "https://a6827308a01f511e9a3340ac8dfed40d-1050376951.eu-west-1.elb.amazonaws.com/v1#{path}"
    end
  end

  class HttpHelper

    def self.post url, session, opts
      execute url, :post, session, opts
    end

    def self.get url, session, opts
      execute url, :get, session, opts
    end

    def self.patch url, session, opts
      execute url, :patch, session, opts
    end

    def self.execute url, method, session, opts
      begin
        res = RestClient::Request.execute(
            url: url,
            method: method,
            payload: opts[:payload] || {},
            headers: {accept: "application/json", "Authorization" => session ? session.token : opts[:authorization]},
            verify_ssl: false)

        # HTTP OK
        if expected(res.code, opts[:expects])
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

    def self.expected(recv, expected)
      # process list
      if expected.respond_to? :each
        expected.include? recv
      else
        expected == recv
      end
    end
  end
end