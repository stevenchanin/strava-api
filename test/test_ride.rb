require 'helper'
require 'mocha'
require 'json'

class TestRide < Test::Unit::TestCase
  def setup
    @s = StravaApi::Base.new

    api_result = JSON.parse rides_index_by_club_json
    api_result.stubs(:parsed_response).returns("")
    StravaApi::Base.stubs(:get).with('/rides', { :query => {'clubId' => 23} }).returns(api_result)

    @ride = @s.rides(:club_id => 23).first
  end
  
  def test_show
    api_result = JSON.parse ride_show_method_json
    api_result.stubs(:parsed_response).returns("")
    StravaApi::Base.stubs(:get).with('/rides/191846', { :query => {} }).returns(api_result)

    assert @ride.id == 191846
    assert @ride.name == "from SVRMC"
    assert @ride.distance.nil?
    assert @ride.location.nil?

    result = @ride.show
    assert result.is_a?(StravaApi::Ride)
    
    assert @ride.id == 191846
    assert @ride.name == "from SVRMC"
    assert @ride.distance == 12958.6
    assert @ride.location == "San Luis Obispo, CA"
  end

  def test_efforts
    api_result = JSON.parse ride_effort_method_json
    api_result.stubs(:parsed_response).returns("")
    StravaApi::Base.stubs(:get).with('/rides/191846/efforts', { :query => {} }).returns(api_result)

    efforts = @ride.efforts
    
    assert efforts.is_a?(Array)
    assert efforts.size == 1
    efforts.each do |effort|
      assert effort.is_a?(StravaApi::Effort)
    end
  end
  
end