# frozen_string_literal: true

# Exception for auth requests that fail because of authentication problems - either explicit
# rejection or back-off
module Stats
  class Unauthenticated < StandardError; end
end
