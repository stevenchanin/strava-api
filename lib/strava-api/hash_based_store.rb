module StravaApi
  class HashBasedStore
    def initialize(connection, attribute_map, nested_class_map, options)
      @connection = connection
      @valid_attributes = attribute_map
      @nested_class_map = nested_class_map
    
      @values = {}
      @valid_attributes.each do |json_key, ruby_key|
        value = options[json_key]
        @values[ruby_key] = value.is_a?(Hash) ? @nested_class_map[ruby_key].new(@connection, value) : value
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
    
    #cleanup how StravaApi objects are displayed in irb
    alias_method :original_inspect, :inspect
    alias_method :inspect, :to_s
    
    def merge(other)
      @valid_attributes.each do |json_key, ruby_key|
        @values[ruby_key] = other[ruby_key] if other[ruby_key]
      end
    end
    
    def method_missing(symbol, *args)
      if @valid_attributes.values.include?(symbol)
        @values[symbol]
      else
        raise InternalError
      end
    end
  end
end