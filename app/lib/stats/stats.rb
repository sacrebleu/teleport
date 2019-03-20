module Stats
  class Stats
    def self.core_stats(number)

      url = WhatsappUrl.metrics(number, "/v1/stats/app?format=prometheus")

      code, res = HttpApi.get(url,
                              Authenticator.authorize(number), {format: :raw}
      )

      if code == :ok
        [res, 200]
      else
        [res[:body], res["code"]]
      end
    end

    def self.db_stats(number)

      url = WhatsappUrl.metrics(number, "/v1/stats/db?format=prometheus")

      code, res = HttpApi.get(url,
                              Authenticator.authorize(number), {format: :raw}
      )

      if code == :ok
        [res, 200]
      else
        [res[:body], res["code"]]
      end
    end
  end
end