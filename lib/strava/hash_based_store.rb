module Strava
  class HashBasedStore
    def initialize(attribute_map, nested_class_map, options)
      @valid_attributes = attribute_map
      @nested_class_map = nested_class_map
    
      @values = {}
      @valid_attributes.each do |json_key, ruby_key|
        value = options[json_key]
        @values[ruby_key] = value.is_a?(Hash) ? @nested_class_map[ruby_key].new(value) : value
      end
    end
  
    def [](key)
      @values[key]
    end
  
    #This needs to be explicit because otherwise you get the Object#id method (which is depreciated) rather than
    #method missing getting called
    def id
      @values[:id]
    end

    def to_s
      result = []
      @values.each do |key, value|
        result << ":#{key} => #{value}" if value
      end
      
      "#<#{self.class} [#{result.join(', ')}]>"
    end
    
    #cleanup how Strava objects are displayed in irb
    alias_method :original_inspect, :inspect
    alias_method :inspect, :to_s
    
    def method_missing(symbol, *args)
      if @valid_attributes.values.include?(symbol)
        @values[symbol]
      else
        raise InternalError
      end
    end
  end
end