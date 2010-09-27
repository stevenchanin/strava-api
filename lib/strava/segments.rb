module Strava
  module Segments
    #returns all segments, don't need an offset
    def segments(name)
      result = call("segments", "segments", {:name => name})

      result["segments"].collect {|item| Segment.new(item)}
    end

    def segment_show(id)
      result = call("segments/#{id}", "segment", {})

      Segment.new(result["segment"])
    end

    def segment_efforts(id, options = {})
      options_map = {
        :club_id => 'clubId',
        :athlete_id => 'athleteId',
        :athlete_name => 'athleteName',
        :start_date => 'startDate',
        :end_date => 'endDate',
        :start_id => 'startId',
        :best => 'best',
        :offset => 'offset'
      }
      
      #convert between rails format names and camel case
      filtered_options = {}
      options_map.each_pair do |key, converted|
        filtered_options[converted] = options[key] if options[key]
      end

      result = call("segments/#{id}/efforts", "efforts", filtered_options)

      result["efforts"].collect {|effort| Effort.new(effort)}
    end
  end
end