module Stats
  class Metrics

    def self.fetch(number)

      url = WhatsappUrl.metrics(number, "/metrics?format=prometheus")

      res, code = Authenticator.authorize(number)
      return [res, code] unless code == 200

      code, res = HttpApi.get(url,
                               res, {format: :raw}
      )

      if code == :ok
        [res, 200]
      else
        [res[:body], res["code"]]
      end
    end
  end
end