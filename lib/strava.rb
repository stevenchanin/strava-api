require 'httparty'

module Strava
  class InvalidResponseError < StandardError; end
  
  class CommandError < StandardError; end

  class NetworkError < StandardError; end
  
  class InternalError < StandardError; end
  
  class HashBasedStore
    def initialize(attribute_map, nested_class_map, options)
      @valid_attributes = attribute_map
      @nested_class_map = nested_class_map
    
      @values = {}
      @valid_attributes.each do |json_key, ruby_key|
        value = options[json_key]
        @values[ruby_key] = value.is_a?(Hash) ? @nested_class_map[ruby_key].new(value) : value
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
      super(ATTRIBUTE_MAP, {}, options)
    end
  end

  class Member < HashBasedStore
    ATTRIBUTE_MAP = {'name' => :name, 'id' => :id, 'username' => :username }
    def initialize(options = {})
      super(ATTRIBUTE_MAP, {}, options)
    end
  end
  
  class Bike < HashBasedStore
    ATTRIBUTE_MAP = {'name' => :name, 'id' => :id }
    def initialize(options = {})
      super(ATTRIBUTE_MAP, {}, options)
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
      "maximumSpeed" => :maximum_speed,
      "athlete" => :athlete, 
      "bike" => :bike
    }
    
    NESTED_CLASS_MAP = { :athlete => Member, :bike => Bike }
    
    def initialize(options = {})
      super(ATTRIBUTE_MAP, NESTED_CLASS_MAP, options)
    end
  end #class Ride
  
  # {
  #   "name":"Panoramic to Pan Toll",
  #   "id":156,
  #   "climbCategory":"4",
  #   "elevationGain":151.728,
  #   "elevationHigh":458.206,
  #   "elevationLow":304.395,
  #   "distance":2378.34,
  #   "averageGrade":6.50757
  # }
  class Segment < HashBasedStore
    ATTRIBUTE_MAP = {
      'name' => :name,
      'id' => :id,
      "climbCategory" => :climb_category,
      "elevationGain" => :elevation_gain,
      "elevationHigh" => :elevation_high,
      "elevationLow" => :elevation_low,
      "distance" => :distance,
      "averageGrade" => :average_grade
    }
    def initialize(options = {})
      super(ATTRIBUTE_MAP, {}, options)
    end
  end


  # {
  #   "id"=>688432, 
  #   "elapsedTime"=>598, 
  #   "segment"=>{"name"=>"Panoramic to Pan Toll","id"=>156},
  #   
  #   "athlete"=>{"name"=>"Julian Bill", "username"=>"jbill", "id"=>1139},
  #   "averageSpeed"=>14317.7658862876,
  #   "startDate"=>"2010-02-28T18:10:07Z", 
  #   "timeZoneOffset"=>-8.0, 
  #   "maximumSpeed"=>18894.384, 
  #   "averageWatts"=>287.765, 
  #   "elevationGain"=>151.408, 
  #   "ride"=>{"name"=>"02/28/10 San Francisco, CA", "id"=>77563}, 
  #   "movingTime"=>598, 
  #   "distance"=>2344.82, 
  #
  #   "rank" => 1
  # }
  class Effort < HashBasedStore
    ATTRIBUTE_MAP = {
      "id" => :id,
      "elapsedTime" => :elapsed_time,
      "segment" => :segment,

      "athlete" => :athlete,
      "averageSpeed" => :average_speed,
      "startDate" => :start_date,
      "timeZoneOffset" => :time_zone_offset,
      "maximumSpeed" => :maximum_speed,
      "averageWatts"=> :average_watts,
      "elevationGain"=> :elevation_gain,
      "ride" => :ride,
      "movingTime" => :moving_time,
      "distance"=> :distance,
      "rank" => :rank
    }

    NESTED_CLASS_MAP = { :segment => Segment, :athlete => Member, :ride => Ride }

    def initialize(options = {})
      super(ATTRIBUTE_MAP, NESTED_CLASS_MAP, options)
    end
  end #class Effort
end

require 'strava/clubs'
require 'strava/rides'
require 'strava/base'
