# frozen_string_literal: true

# generator for URLS - take a MO and a path and generate a URL with a FQDN and path
class WhatsappUrl
  def self.generate(number, path)
    "#{Rails.application.config.x.api_endpoint.gsub('MO', number)}#{path}"
  end

  def self.metrics(number, path)
    "#{Rails.application.config.x.metrics_endpoint.gsub('MO', number)}#{path}"
  end
end
