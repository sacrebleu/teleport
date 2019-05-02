# frozen_string_literal: true

module Stats
  # facade onto HttpApi for extracting cluster health metrics
  class Health < ProtectedResource
    # returns an aggregation of failures for failing clusters, grouped by whatsapp MO
    def self.aggregate
      res = fetch_unhealthy.map do |n, h|
        errors = h.map do |k, v|
          [k.split(':')[1],
           v['gateway_status'] || collate_errors(v['errors'])]
        end
        [n, errors]
      end

      res.each_with_object([]) do |val, obj|
        val[1].map { |v| obj << [val[0], v].flatten }
      end
    end

    # collate errors into more meaningful strings for display
    def self.collate_errors(arr)
      arr.nil? ? [] : arr.collect { |a| "#{a['title']} (#{a['code']}) - #{a['details']}" }.join(', ')
    end

    # fetch unhealthy status checks
    def self.fetch_unhealthy
      Lookup.all.pluck(:number)
            .map { |number| [number, Rails.cache.fetch("health/#{number}") || nil] }
            .reject { |_, v| v.nil? }
    end

    # fetch the stats for a Whatsapp cluster by MO
    def self.fetch(number)
      url = WhatsappUrl.generate(number, '/health')

      res, code = authorize(number)
      return [res, code] unless code == 200

      code, res = HttpApi.get(url, res, format: :raw)
      return [res[:body], res['code']] unless code == :ok

      [JSON.parse(res)['health'], 200]
    end

    # fetch the stats for a whatsapp cluster and return a
    def self.sanity(number)
      url = WhatsappUrl.generate(number, '/health')

      res, code = authorize(number)
      return [res, code] unless code == 200

      code, res = HttpApi.get(url, res, format: :raw)
      return [res[:body], res[:code]] unless code == :ok

      live?(number, res)
    end

    def self.live?(number, response)
      struct = JSON.parse(response)

      live = struct['health'].all? { |_, status| status['gateway_status'] == 'connected' }
      Rails.cache.write("health/#{number}", struct['health'], expires_in: 1.minutes) unless live

      [(live ? 1 : 0), 200]
    end
  end
end
