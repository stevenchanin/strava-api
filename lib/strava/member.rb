module Strava
  class Member < HashBasedStore
    ATTRIBUTE_MAP = {'name' => :name, 'id' => :id, 'username' => :username }
    def initialize(options = {})
      super(ATTRIBUTE_MAP, {}, options)
    end
  end
end