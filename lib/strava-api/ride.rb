module StravaApi
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
    
    def initialize(connection, options = {})
      super(connection, ATTRIBUTE_MAP, NESTED_CLASS_MAP, options)
    end

    def show
      self.merge(@connection.ride_show(self.id))
      self
    end

    def efforts
      @connection.ride_efforts(self.id)
    end
    
    def streams
      @connection.ride_streams(self.id)
    end
  end #class Ride
end