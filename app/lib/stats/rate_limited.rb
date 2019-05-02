# frozen_string_literal: true

module Stats
  # exception that is raised when the whatsapp api replies with a 429 too many requests
  class RateLimited < StandardError; end
end
