module StravaApi
  class Member < HashBasedStore
    ATTRIBUTE_MAP = {'name' => :name, 'id' => :id, 'username' => :username }
    def initialize(connection, options = {})
      super(connection, ATTRIBUTE_MAP, {}, options)
    end
  end
end