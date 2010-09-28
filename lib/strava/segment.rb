module Strava
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
    def initialize(connection, options = {})
      super(connection, ATTRIBUTE_MAP, {}, options)
    end
  end
end