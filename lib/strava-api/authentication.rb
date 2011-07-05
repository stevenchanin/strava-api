module StravaApi
  module Authentication
    # authenticate a user with their Strava credentials.
    def login(email, password)
      result = call("authentication/login", nil, {:email => email, :password => password}, :post)
      User.new(self, result)
    end
  end
end
