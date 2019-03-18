class WhatsappUrl
  def self.generate(number, path)
    "#{Rails.application.config.x.api_endpoint.gsub("MO", number)}#{path}"
  end

  def self.metrics(number, path)
    "#{Rails.application.config.x.metrics_endpoint.gsub("MO", number)}#{path}"
  end
end