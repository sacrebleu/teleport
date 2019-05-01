# frozen_string_literal: true

module Stats
  # Customer is a simple facade in front of the Rails Cache for customer names
  class Customer
    QUERY = <<~QUERY
      SELECT wa.country, wa.phone
      FROM   whatsapp_config wa
      LEFT OUTER JOIN lookups
      ON (wa.phone = lookups.phone)
      WHERE lookups.phone IS NULL
    QUERY

    # fetch and cache customer details with an expiry period passed as an option
    def self.fetch_company_name(number, options = { expires_in: 24.hours })
      Rails.cache.fetch("company_name/#{number}", options) do
        lookup = lookup_number(number)
        creds = Credential.where(country: lookup.country, phone: lookup.phone).first
        creds.company_name
      end
    end

    def self.lookup_number(number)
      l = Lookup.find_by_number(number)

      unless l
        populate_lookups
        l = Lookup.find_by_number(number)

        raise "No such number in the configuration database: #{number}" unless l
      end
      l
    end

    def self.populate_lookups
      res = ActiveRecord::Base.connection.execute QUERY

      res.each { |record| Lookup.create!(country: record[0], phone: record[1], number: "#{record[0]}#{record[1]}") }

      Rails.logger.info "Populated lookups table with #{res.count} missing records"
    end
  end
end
