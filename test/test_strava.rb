require 'helper'
require 'mocha'
require 'json'

class TestStravaApi < Test::Unit::TestCase
  def setup
    @s = StravaApi::Base.new
  end
  
  def test_effort_show
    #curl http://www.strava.com/api/v1/efforts/688432
    api_result = JSON.parse '{"effort":{"ride":{"name":"02/28/10 San Francisco, CA","id":77563},"averageSpeed":14317.7658862876,"startDate":"2010-02-28T18:10:07Z","averageWatts":287.765,"startDateLocal":"2010-02-28T10:10:07Z","maximumSpeed":18894.384,"timeZoneOffset":-8.0,"athlete":{"username":"julianbill","name":"Julian Bill","id":1139},"elevationGain":151.408,"distance":2344.82,"elapsedTime":598,"segment":{"name":"Panoramic to Pan Toll","id":156},"id":688432,"movingTime":598}}'
    api_result.stubs(:parsed_response).returns("")
    StravaApi::Base.stubs(:get).with('/efforts/688432', { :query => {} }).returns(api_result)

    result = @s.effort_show(688432)
    
    assert result.is_a?(StravaApi::Effort)
    assert result.elapsed_time == 598
    assert result.athlete.is_a?(StravaApi::Member)
    assert result.athlete.name == "Julian Bill"
    assert result.average_speed == 14317.7658862876
    assert result.id == 688432
    #assert result.start_date == Time.parse('2010-02-28T18:10:07Z')
    assert result.time_zone_offset == -8.0
    assert result.maximum_speed == 18894.384
    assert result.average_watts == 287.765
    assert result.elevation_gain == 151.408
    assert result.ride.is_a?(StravaApi::Ride)
    assert result.ride.name == "02/28/10 San Francisco, CA"
    assert result.moving_time == 598
    assert result.distance == 2344.82
    assert result.segment.is_a?(StravaApi::Segment)
    assert result.segment.name == "Panoramic to Pan Toll"
  end
end
