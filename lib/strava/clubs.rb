module Strava
  module Clubs
    def clubs(name)
      result = call("clubs", "clubs", {:name => name})

      result["clubs"].collect {|item| Club.new(item["name"], item["id"])}
    end
    
    def club_show(id)
      result = call("clubs/#{id}", "club", {})

      club_data = result["club"]
      Club.new(club_data["name"], club_data["id"], club_data["description"], club_data["location"])
    end
    
    def club_members(id)
      result = call("clubs/#{id}/members", "members", {})

      result["members"].collect {|item| Member.new(item["name"], item["id"])}
    end
  end
end
