module StravaApi
  class Base
    include HTTParty
    
    include StravaApi::Clubs
    include StravaApi::Rides
    include StravaApi::Segments
    include StravaApi::Efforts
    
    format :json
    base_uri 'www.strava.com/api/v1'
    
    attr_reader :errors
    
    def initialize
      @errors = []
    end
    
    def call(command, key, options)
      begin
        result = self.class.get("/#{command}", :query => options)
      rescue HTTParty::UnsupportedFormat, HTTParty::UnsupportedURIScheme, HTTParty::ResponseError, HTTParty::RedirectionTooDeep
        raise NetworkError.new
      end
      
      if result && result.parsed_response == "<html><body><h1>500 Internal Server Error</h1></body></html>"
        @errors << "Strava returned a 500 error"
        raise CommandError.new 
      end
      
      @errors << result["error"] if result && result["error"]
      raise InvalidResponseError.new if result.nil? || !result["error"].blank? || result[key].nil?
      
      result
    end
  end
end