module Strava
  class Bike < HashBasedStore
    ATTRIBUTE_MAP = {'name' => :name, 'id' => :id }
    def initialize(connection, options = {})
      super(connection, ATTRIBUTE_MAP, {}, options)
    end
  end
end