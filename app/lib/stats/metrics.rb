module Stats
  class Metrics

    def self.fetch(number)

      url = WhatsappUrl.metrics(number, "/metrics?format=prometheus")

      auth = Authenticator.authorize(number)
      return [nil, 429] unless auth

      code, res = HttpApi.get(url,
                               auth, {format: :raw}
      )

      if code == :ok
        [res, 200]
      else
        [res[:body], res["code"]]
      end
    end
  end
end