module Stats
  class Metrics

    def self.fetch(number)

      url = WhatsappUrl.generate(number, "/metrics?format=prometheus")

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