module Stats
  class Health

    def self.fetch(number)

      url = WhatsappUrl.generate(number, "/health")

      res, code = Authenticator.authorize(number)
      return [res, code] unless code == 200

      code, res = HttpApi.get(url,
                               res, {format: :raw}
      )

      if code == :ok
        res = JSON.parse(res)

        Rails.logger.info res["health"].inspect

        [res["health"], 200]
      else
        [res[:body], res["code"]]
      end
    end

    def self.sanity(number)

      url = WhatsappUrl.generate(number, "/health")

      res, code = Authenticator.authorize(number)
      return [res, code] unless code == 200

      code, res = HttpApi.get(url,
                              res, {format: :raw}
      )

      if code == :ok
        res = JSON.parse(res)

        live = res["health"].all? { |_, status|  status["gateway_status"] == "connected" }

        [(live ? 1 : 0), 200]
      else
        [res[:body], res["code"]]
      end
    end

  end
end