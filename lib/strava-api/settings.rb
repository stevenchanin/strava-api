module StravaApi
  class Settings < HashBasedStore
    ATTRIBUTE_MAP = {"sampleRate" => :sample_rate, 
                     "continuousGps" => :continuous_gps, 
                     "accuracy" => :accuracy, 
                     "distanceFilter" => :distance_filter, 
                     "maxSearchTime" => :max_search_time, 
                     "minStaleTime" => :min_stale_time, 
                     "minAccuracy" => :min_accuracy}
                     
    def initialize(connection, options = {})
      super(connection, ATTRIBUTE_MAP, {}, options)
    end
  end
end