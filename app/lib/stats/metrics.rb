# frozen_string_literal: true

module Stats
  # facade onto cluster prometheus metrics
  class Metrics < ProtectedResource
    # fetch the cluster metrics for a whatsapp cluster by MO
    def self.fetch(number)
      url = WhatsappUrl.metrics(number, 'metrics?format=prometheus')

      res, code = authorize(number)
      return [res, code] unless code == 200

      code, res = HttpApi.get(url, res, format: :raw)

      code == :ok ? [res, 200] : [res[:body], res[:code]]
    end
  end
end
