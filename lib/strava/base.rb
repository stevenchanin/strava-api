module Strava
  class Base
    include HTTParty
    
    include Strava::Clubs
    
    format :json
    base_uri 'www.strava.com/api/v1'
    
    def initialize
    end
    
    def call(command, key, options)
      begin
        result = self.class.get("/#{command}", :query => options)
      rescue
        raise NetworkError.new
      end
      
      raise CommandError.new if result && result.parsed_response == "<html><body><h1>500 Internal Server Error</h1></body></html>"
      raise InvalidResponseError.new if result.nil? || !result["error"].blank? || result[key].nil?
      
      result
    end
  end
end