# frozen_string_literal: true

module Stats
  # Facade for retrieving cluster prometheus status by Whatsapp MO
  class Stats < ProtectedResource
    def self.core_stats(number)
      url = WhatsappUrl.metrics(number, '/v1/stats/app?format=prometheus')

      res, code = authorize(number)
      return [res, code] unless code == 200

      code, res = HttpApi.get(url, res, format: :raw)

      if code == :ok
        [res, 200]
      else
        [res[:body], res['code']]
      end
    end

    def self.db_stats(number)
      url = WhatsappUrl.metrics(number, '/v1/stats/db?format=prometheus')

      res, code = authorize(number)
      return [res, code] unless code == 200

      code, res = HttpApi.get(url, res, format: :raw)

      if code == :ok
        [res, 200]
      else
        [res[:body], res['code']]
      end
    end
  end
end
