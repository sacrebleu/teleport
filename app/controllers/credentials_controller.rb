# permit external setting of credentials for authentication onto whatsapp clusters for stat retrieval
class CredentialsController < ApplicationController

  def set_credentials
    c = Credential.find_by_number(params[:number])

    if c.nil?
      c = Credential.new(number: params[:number], username: params[:username], password: params[:password])
    else
      c.password = params[:password]
    end
    c.save!

    Rails.logger.info "Flushing existing tokens for cluster #{params[:number]}"
    Rails.cache.delete("tokens/#{params[:number]}")

    render json: {}, status: :ok
  end

  def populate
    res = ActiveRecord::Base.connection.execute(<<~EOF
    SELECT wa.country, wa.phone
    FROM   whatsapp_config wa
		LEFT OUTER JOIN lookups
		ON (wa.phone = lookups.phone)
		WHERE lookups.phone IS NULL
EOF
    )

    Rails.logger.info res.count.inspect

    res.each do |record|
      Lookup.create!(country: record[0], phone: record[1], number: "#{record[0]}#{record[1]}")
      Rails.logger.info record.inspect
    end

    render json:{}, status: :ok
  end

end
