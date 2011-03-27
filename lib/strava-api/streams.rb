module StravaApi

  class Streams < HashBasedStore
    ATTRIBUTE_MAP = {
      "altitude" => :altitude,
      "cadence" => :cadence,
      "distance" => :distance,
      "heartrate" => :heartrate,
      "latlng" => :latlng,
      "time" => :time,
      "watts" => :watts,
      "watts_calc" => :watts_calc
    }

    NESTED_CLASS_MAP = {}

    def initialize(connection, options = {})
      super(connection, ATTRIBUTE_MAP, NESTED_CLASS_MAP, options)
    end
  end #class Streams
end