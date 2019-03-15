module Cluster
  class Session

    attr_reader :session_token, :number

    def initialize(n)
      @number = n
    end

    def self.create(number, username, password)
      s = Session.new(number)
      s.authenticate(username, password)
      s
    end

    # authenticate against the remote server and retrieve a token
    def authenticate(username, password)
      print "Authenticating with remote server... "
      @session_token = Api.authenticate number, basic_auth(username, password)
    end

    def token
      "Bearer #{session_token}"
    end

    def basic_auth(username, password)
      hash = Base64::encode64("#{username}:#{password}").strip
      "Basic #{hash}"
    end
  end
end