module Strava
  module Efforts
    def effort_show(id)
      result = call("efforts/#{id}", "effort", {})

      Effort.new(self, result["effort"])
    end
  end
end
