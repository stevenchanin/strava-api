module Strava
  module Clubs
    def clubs(name)
      result = call("clubs", "clubs", {:name => name})

      result["clubs"].collect {|item| Club.new(item)}
    end
    
    def club_show(id)
      result = call("clubs/#{id}", "club", {})

      Club.new(result["club"])
    end
    
    def club_members(id)
      result = call("clubs/#{id}/members", "members", {})

      result["members"].collect {|item| Member.new(item)}
    end
  end
end
