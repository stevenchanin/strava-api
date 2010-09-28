module Strava
  class Bike < HashBasedStore
    ATTRIBUTE_MAP = {'name' => :name, 'id' => :id }
    def initialize(options = {})
      super(ATTRIBUTE_MAP, {}, options)
    end
  end
end