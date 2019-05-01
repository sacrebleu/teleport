# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20_190_501_095_859) do
  create_table 'lookups' do |t|
    t.string 'number'
    t.string 'country'
    t.string 'phone'
  end

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
    t.datetime 'time_data_backedup'
    t.string 'data_password', limit: 45
    t.integer 'shard_count', limit: 1, default: 1
    t.string 'deployment_type', limit: 20, default: 'npe'
  end
end
