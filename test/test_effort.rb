require 'helper'
require 'mocha'
require 'json'

class TestEffort < Test::Unit::TestCase
  def setup
    @s = Strava::Base.new

    api_result = JSON.parse ride_efforts_json
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/rides/77563/efforts', {:query => {}}).returns(api_result)
    
    @effort = @s.ride_efforts(77563).first
  end

  def test_show
    api_result = JSON.parse effort_show_method
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/efforts/2231990', { :query => {} }).returns(api_result)

    assert @effort.athlete.nil?
    assert @effort.average_speed.nil?

    result = @effort.show
    
    assert result.is_a?(Strava::Effort)
    
    assert @effort.athlete.name == "Julian Bill"
    assert @effort.average_speed == 20149.3205741627
  end
end
