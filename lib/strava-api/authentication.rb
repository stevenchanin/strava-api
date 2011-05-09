module StravaApi
  module Authentication
    
    # def rides(options = {})
    #   options_map = {
    #     :club_id => 'clubId',
    #     :athlete_id => 'athleteId',
    #     :athlete_name => 'athleteName',
    #     :start_date => 'startDate',
    #     :end_date => 'endDate',
    #     :start_id => 'startId',
    #     :offset => 'offset'
    #   }
    #   
    #   #convert between rails format names and camel case
    #   filtered_options = {}
    #   options_map.each_pair do |key, converted|
    #     filtered_options[converted] = options[key] if options[key]
    #   end
    # 
    #   raise StravaApi::CommandError if filtered_options.empty?
    # 
    #   result = call("rides", "rides", filtered_options)
    #   result["rides"].collect {|item| Ride.new(self, item)}
    # end
    
    def login(email, password)
      result = call("authentication/login", nil, {:email => email, :password => password}, :post)
      User.new(self, result)
    end
    
  end
end
