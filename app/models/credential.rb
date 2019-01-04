class Credential < ApplicationRecord
  self.table_name = "whatsapp_config"

  def id
    @id = country + phone
  end
end