require 'httparty'

module Strava
  class InvalidResponseError < StandardError; end
  
  class CommandError < StandardError; end

  class NetworkError < StandardError; end
  
  class InternalError < StandardError; end
  
  class HashBasedStore
    def initialize(attribute_map, options)
      @valid_attributes = attribute_map
      
      @values = {}
      @valid_attributes.each do |json_key, ruby_key|
        @values[ruby_key] = options[json_key]
      end

    end
    
    def [](key)
      @values[key]
    end
    
    #This needs to be explicit because otherwise you get the Object#id method (which is depreciated) rather than
    #method missing getting called
    def id
      @values[:id]
    end
    
    def to_s
      result = []
      @values.each do |key, value|
        result << ":#{key} => #{value}" if value
      end
      
      "#<#{self.class} [#{result.join(', ')}]>"
    end
    
    def method_missing(symbol, *args)
      if @valid_attributes.values.include?(symbol)
        @values[symbol]
      else
        raise InternalError
      end
    end
  end

  class Club < HashBasedStore
    ATTRIBUTE_MAP = {'name' => :name, 'id' => :id, 'description' => :description, 'location' => :location }
    def initialize(options = {})
      super(ATTRIBUTE_MAP, options)
    end
  end

  class Member < HashBasedStore
    ATTRIBUTE_MAP = {'name' => :name, 'id' => :id }
    def initialize(options = {})
      super(ATTRIBUTE_MAP, options)
    end
  end
  
  # {"ride":{
  #   "timeZoneOffset":-8.0,
  #   "elevationGain":1441.02,
  #   "location":"San Francisco, CA",
  #   "elapsedTime":14579,
  #   "description":null,
  #   "name":"02/28/10 San Francisco, CA",
  #   "movingTime":12748,
  #   "averageSpeed":23260.8064010041,
  #   "athlete":{"username":"julianbill","name":"Julian Bill","id":1139},
  #   "distance":82369.1,
  #   "startDate":"2010-02-28T16:31:35Z",
  #   "averageWatts":175.112,
  #   "bike":{"name":"Serotta Legend Ti","id":903},
  #   "startDateLocal":"2010-02-28T08:31:35Z",
  #   "id":77563,
  #   "maximumSpeed":64251.72
  # }}
  class Ride < HashBasedStore
    ATTRIBUTE_MAP = {
      "timeZoneOffset" => :time_zone_offset,
      "elevationGain" => :elevation_gain, 
      "location" => :location,
      "elapsedTime" => :elapsed_time,
      "description" => :description,
      "name" => :name,
      "movingTime" => :moving_time,
      "averageSpeed" => :average_speed,
      "distance" => :distance,
      "startDate" => :start_date,
      "averageWatts" => :average_watts,
      "startDateLocal" => :start_date_local,
      "id" => :id,
      "maximumSpeed" => :maximum_speed
    }
    #:athlete, :bike,
    
    def initialize(options = {})
      super(ATTRIBUTE_MAP, options)
    end
  end #class Ride
  
  #{
  #   "elapsed_time":598,
  #   "segment":{"name":"Panoramic to Pan Toll","id":156},
  #   "id":688432
  #}
  class Effort < HashBasedStore
    ATTRIBUTE_MAP = {
      'elapsed_time' => :elapsed_time,
      'id' => :id
    }
    def initialize(options = {})
      super(ATTRIBUTE_MAP, options)
    end
  end #class Effort
end

require 'strava/clubs'
require 'strava/rides'
require 'strava/base'
