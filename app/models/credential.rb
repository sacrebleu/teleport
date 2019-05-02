# frozen_string_literal: true

# model for ActiveRecord credential model
class Credential < ApplicationRecord
  self.table_name = 'whatsapp_config'

  def id
    @id ||= country + phone
  end

  # def endpoint
  #   @endpoint ||= generate
  # end

  # def generate
  #   s = "#{config.x.api_endpoint}"
  #   s.gsub!("MO", id)
  #   s.gsub!("ENV.", config.x.env)
  #   s
  # end
end
