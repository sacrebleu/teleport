# frozen_string_literal: true

module Stats
  # encapsulates web resources that require a valid session token to reach
  class ProtectedResource
    # check whether a number can be authorized for access using the stored credentials or
    # cached session
    def self.authorize(number)
      Authenticator.authorize(number)
    end
  end
end
