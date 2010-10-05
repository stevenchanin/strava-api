module StravaApi
  class Club < HashBasedStore
    ATTRIBUTE_MAP = {'name' => :name, 'id' => :id, 'description' => :description, 'location' => :location }
    def initialize(connection, options = {})
      super(connection, ATTRIBUTE_MAP, {}, options)
    end
    
    def show
      self.merge(@connection.club_show(self.id))
      self
    end
    
    def members
      @connection.club_members(self.id)
    end
  end
end