module Stats
  class Stats
    def self.core_stats(number)

      url = WhatsappUrl.metrics(number, "/v1/stats/app?format=prometheus")

      auth = Authenticator.authorize(number)
      return [nil, 429] unless auth

      code, res = HttpApi.get(url, auth, {format: :raw}
      )

      if code == :ok
        [res, 200]
      else
        [res[:body], res["code"]]
      end
    end

    def self.db_stats(number)

      url = WhatsappUrl.metrics(number, "/v1/stats/db?format=prometheus")

      auth = Authenticator.authorize(number)
      return [nil, 429] unless auth
      code, res = HttpApi.get(url, auth, {format: :raw}
      )

      if code == :ok
        [res, 200]
      else
        [res[:body], res["code"]]
      end
    end
  end
end