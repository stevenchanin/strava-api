module StravaApi
  class Base
    include HTTParty

    include StravaApi::Authentication
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

    def call(command, key, options, *args)
      method = args[0] || :get

      begin
        if(method == :get)
          result = self.class.get("/#{command}", :query => options)
        else
          result = self.class.post("/#{command}", :body => options)
        end

      rescue HTTParty::UnsupportedFormat, HTTParty::UnsupportedURIScheme, HTTParty::ResponseError, HTTParty::RedirectionTooDeep
        raise NetworkError.new
      end

      if result && result.parsed_response == "<html><body><h1>500 Internal Server Error</h1></body></html>"
        @errors << "Strava returned a 500 error"
        raise CommandError.new
      end

      if result && result["error"]
        @errors << result["error"]
        raise AuthenticationError.new if result["error"] == "Invalid email or password."
        raise InvalidResponseError.new
      end

      raise InvalidResponseError.new if result.nil? || (!key.nil? && result[key].nil?)

      result
    end
  end
end