require "rubygems"

require "optparse"
require "json"
require "securerandom"
require "base64"

require 'rest-client'

# require everything in /lib
Dir["#{File.dirname(__FILE__)}/lib/*.rb"].each { |file| require file }

# this script orchestrates the configuration of a newly created whatsapp cluster.  It is written in ruby for convenience and brevity
# but can easily be refactored to python, go or shell script as necessary

options = Parser.parse_commandline

return unless options.set

puts "options: #{options.action}"

session = Session.create(options.number, 'admin', options.password)

# deliver a test MT to the designated test number
if options.action == :test
	puts "Testing number #{options.number.cyan} delivering MT to #{options.test_mt.cyan}"

	session = Session.create(options.number, 'admin', options.password)

	print "Sending test mt..."
	code, res = Api.send_test_message(session, options.test_mt)

	puts "#{code.to_s.green} - delivery id: #{res}"
end

# verify a 2fa code
if options.action == :verify
	puts "Verifying 2fa code for cluster #{options.number}"

	print "Sending 2fa verification code..."
	code, res = Api.verify_2fa_token(session, options.tfa_code)

	puts "#{code.to_s.green} - 2fa verified successfully."
end

if options.action == :set_shards
	puts "Setting shard size for cluster #{options.number}"

	code,res = Api.set_shard_count(session, options.shards, options.country_code, options.pin)

	puts "#{code.to_s.green} - shard size successfully set"
end

if options.action == :configure
	puts "Setting up cluster #{options.number} with initial configuration"

	# code, res = Api.update_credentials(session, Base64.encode64("admin:#{options.password}"), options.new_password)

	# if code
		puts "Authenticated and updated password".green

		code, res = Api.set_webhook(session)

		puts "Set webhook to https://messages.nexmo.com/chatapp/mo/whatsapp/#{session.number.to_s.cyan}"

		puts "Setting cluster config..."

		cert = File.open(options.path, 'r') do |f|
		    f.read
		end

		code, res = Api.initialise_2fa(session, options.country_code, session.number, options.tfa_verify_method, cert, options.pin)
		print "#{code.to_s.green}"
		puts "\nConfig initialised.  2FA should now be triggered."
	# end
end



