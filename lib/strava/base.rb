module Strava
  class Base
    include HTTParty
    
    format :json
    base_uri 'www.strava.com/api/v1'
    
    def initialize(club_name)
      @club_name = club_name
    end
  end
end