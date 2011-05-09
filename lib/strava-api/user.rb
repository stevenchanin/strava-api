module StravaApi
  class User < HashBasedStore
    ATTRIBUTE_MAP = {
      "token" => :token,
      "athlete_id" => :athlete_id, 
      "agreedToTerms" => :agreed_to_terms,
      "superUser" => :super_user,
      "defaultSettings" => :default_settings
    }
    
    NESTED_CLASS_MAP = { :default_settings => Settings }
    
    def initialize(connection, options = {})
      super(connection, ATTRIBUTE_MAP, NESTED_CLASS_MAP, options)
    end

  end
end