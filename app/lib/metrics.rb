class Metrics

	def self.fetch(number)
		code, res = HttpApi.get("https://api.#{number}.wa.prod.nexmo.cloud/metrics?format=prometheus",
			Authenticator.authorize(number), { 	format: :raw }
			)

		if code == :ok
			[ res, 200 ]
		else
			[ res[:body], res["code"] ]
		end
	end

end