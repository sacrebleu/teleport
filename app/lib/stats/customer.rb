module Stats
  class Customer
    #fetch and cache customer details with an expiry period passed as an option
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
  end
end