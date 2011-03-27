module StravaApi
  module Rides
    def rides(options = {})
      options_map = {
        :club_id => 'clubId',
        :athlete_id => 'athleteId',
        :athlete_name => 'athleteName',
        :start_date => 'startDate',
        :end_date => 'endDate',
        :start_id => 'startId',
        :offset => 'offset'
      }
      
      #convert between rails format names and camel case
      filtered_options = {}
      options_map.each_pair do |key, converted|
        filtered_options[converted] = options[key] if options[key]
      end

      raise StravaApi::CommandError if filtered_options.empty?

      result = call("rides", "rides", filtered_options)
      result["rides"].collect {|item| Ride.new(self, item)}
    end
    
    def ride_show(id)
      result = call("rides/#{id}", "ride", {})
    
      Ride.new(self, result["ride"])
    end
    
    #returns all efforts, don't need an offset
    def ride_efforts(id)
      result = call("rides/#{id}/efforts", "efforts", {})
    
      result["efforts"].collect {|effort| Effort.new(self, effort)}
    end
    
    def ride_streams(id)
      result = call("streams/#{id}", nil, {})
      Streams.new(self, result.to_hash)
    end
  end
end
