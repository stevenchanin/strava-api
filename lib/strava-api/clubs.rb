module StravaApi
  module Clubs
    #returns all clubs, don't need an offset
    def clubs(name)
      raise StravaApi::CommandError if name.blank?
      
      name = name.strip
      raise StravaApi::CommandError if name.empty?

      result = call("clubs", "clubs", {:name => name})

      result["clubs"].collect {|item| Club.new(self, item)}
    end
    
    def club_show(id)
      result = call("clubs/#{id}", "club", {})

      Club.new(self, result["club"])
    end
    
    #returns all members, don't need an offset
    def club_members(id)
      result = call("clubs/#{id}/members", "members", {})

      result["members"].collect {|item| Member.new(self, item)}
    end
  end
end
