module Strava
  class InvalidResponseError < StandardError; end

  class CommandError < StandardError; end

  class NetworkError < StandardError; end

  class InternalError < StandardError; end
end