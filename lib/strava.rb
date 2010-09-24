require 'httparty'

module Strava
  class InvalidResponseError < StandardError; end
  
  class CommandError < StandardError; end

  class NetworkError < StandardError; end
  
  class Club
    attr_reader :name, :id, :description, :location

    def initialize(name, id, description = "", location = "")
      @name = name
      @id = id
      @description = description
      @location = location
    end
  end

  class Member
    attr_reader :name, :id

    def initialize(name, id)
      @name = name
      @id = id
    end
  end
end

require 'strava/clubs'
require 'strava/base'
