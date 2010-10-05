module StravaApi
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

    def initialize(connection, options = {})
      super(connection, ATTRIBUTE_MAP, NESTED_CLASS_MAP, options)
    end

    def show
      self.merge(@connection.effort_show(self.id))
      self
    end
  end #class Effort
end