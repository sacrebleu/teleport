class WhatsappUrl
  def self.generate(number, path)
    "#{Rails.application.config.x.api_endpoint.gsub("MO", number)}#{path}"
  end
end