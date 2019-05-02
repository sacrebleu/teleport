# frozen_string_literal: true

# migration class to add the core cluster credentials table
class AddWhatappConfig < ActiveRecord::Migration[5.2]
  def change
    create_table 'whatsapp_config' do |t|
      t.string 'country', limit: 4, null: false
      t.string 'phone', limit: 20, null: false
      t.string 'username', limit: 45
      t.string 'password', limit: 45
      t.string 'pin', limit: 6
      t.string 'npe_instance', limit: 45
      t.string 'kubernetes', limit: 45
      t.text 'data', limit: 16_777_215
      t.string 'api_key', limit: 50
      t.string 'company_name', limit: 45
      t.string 'version', limit: 45
      t.timestamp 'time_data_backedup'
      t.string 'data_password', limit: 45
      t.integer 'shard_count', limit: 1, default: 1, unsigned: true
      t.string 'deployment_type', limit: 20, default: 'npe'
    end
  end
end
