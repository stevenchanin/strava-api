require 'helper'
require 'mocha'
require 'json'

class TestRides < Test::Unit::TestCase
  def setup
    @s = Strava::Base.new
  end

  def test_rides_index_no_arguments
    expect_error(Strava::CommandError) { @s.rides }
  end
  
  def test_rides_index_invalid_argument
    expect_error(Strava::CommandError) { @s.rides(:invalid => true) }
  end

  def test_rides_index_by_club
    api_result = JSON.parse rides_index_by_club_json
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/rides', { :query => {'clubId' => 23} }).returns(api_result)

    result = @s.rides(:club_id => 23)
    
    assert result.is_a?(Array)
    
    result.each do |ride|
      assert ride.is_a?(Strava::Ride)
    end
  end

  def test_rides_index_by_athlete
    #curl http://www.strava.com/api/v1/rides?athleteId=779
    api_result = JSON.parse rides_index_by_athlete_json
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/rides', { :query => {'athleteId' => 779} }).returns(api_result)

    result = @s.rides(:athlete_id => 779)
    
    assert result.is_a?(Array)
    
    result.each do |ride|
      assert ride.is_a?(Strava::Ride)
    end
  end

  def test_rides_index_by_club_and_athlete
    #curl "http://www.strava.com/api/v1/rides?clubId=23&athleteId=779"
    api_result = JSON.parse rides_index_by_club_and_athlete_json
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/rides', { :query => {'clubId' => 23, 'athleteId' => 779} }).returns(api_result)

    result = @s.rides(:club_id => 23, :athlete_id => 779)
    
    assert result.is_a?(Array)
    
    result.each do |ride|
      assert ride.is_a?(Strava::Ride)
    end
  end

  def test_rides_index_with_mismatched_club_and_athlete
    #curl "http://www.strava.com/api/v1/rides?clubId=24&athleteId=779"
    api_result = JSON.parse '{"error":"Invalid clubId"}'
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/rides', { :query => {'clubId' => 24, 'athleteId' => 779} }).returns(api_result)

    expect_error(Strava::InvalidResponseError) { @s.rides(:club_id => 24, :athlete_id => 779) }
    
    assert @s.errors.include?("Invalid clubId")
  end
  
  def test_rides_index_ignores_invalid_parameter
    #curl http://www.strava.com/api/v1/rides?athleteId=779
    api_result = JSON.parse rides_index_ignores_invalid_parameter_json
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/rides', { :query => {'athleteId' => 779} }).returns(api_result)

    result = @s.rides(:athlete_id => 779, :xclub_id => 24)
    
    assert result.is_a?(Array)
    
    result.each do |ride|
      assert ride.is_a?(Strava::Ride)
    end
  end
  
  def test_rides_after_start_date
    #curl "http://www.strava.com/api/v1/rides?athleteId=779&startDate=2010-09-21"
    api_result = JSON.parse rides_after_start_date_json
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/rides', { :query => {'athleteId' => 779, 'startDate' => Date.civil(2010,9,21)} }).returns(api_result)

    result = @s.rides(:athlete_id => 779, :start_date => Date.civil(2010,9,21))
    
    assert result.is_a?(Array)
    
    result.each do |ride|
      assert ride.is_a?(Strava::Ride)
      #TODO check that each ride is after 9/21/2010
    end
  end
  
  def test_rides_using_offset
    #curl "http://www.strava.com/api/v1/rides?athleteId=779&startDate=2010-07-1&endDate=2010_09_01"
    api_result = JSON.parse rides_using_offset_json
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/rides', { :query => {'startDate' => Date.civil(2010,7,1),
      'endDate' => Date.civil(2010,7,5)} }).returns(api_result)

    api_result2 = JSON.parse rides_using_offset_50_json
    api_result2.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/rides', { :query => {'startDate' => Date.civil(2010,7,1),
      'endDate' => Date.civil(2010,7,5), 'offset' => 50} }).returns(api_result2)

    set_1 = @s.rides(:start_date => Date.civil(2010,7,1), :end_date => Date.civil(2010,7,5))
    set_2 = @s.rides(:start_date => Date.civil(2010,7,1), :end_date => Date.civil(2010,7,5), :offset => set_1.size)
    
    assert set_1.is_a?(Array)
    assert set_2.is_a?(Array)
    
    set_1.each {|ride| assert ride.is_a?(Strava::Ride)}
    set_2.each {|ride| assert ride.is_a?(Strava::Ride)}
    
    #but there shouldn't be any overlap
    set_1_ids = set_1.collect(&:id)
    set_2_ids = set_2.collect(&:id)
    
    set_1_ids.each do |set_1_id|
      assert !set_2_ids.include?(set_1_id), "Error: #{set_1_id} is included in both sets"
    end
  end

  def test_ride_show
    #curl "http://www.strava.com/api/v1/rides/77563"
    api_result = JSON.parse ride_show_json
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/rides/77563', { :query => {} }).returns(api_result)

    result = @s.ride_show(77563)
    
    assert result.is_a?(Strava::Ride)

    {
      :time_zone_offset => -8.0,
      :elevation_gain => 1441.02,
      :location => "San Francisco, CA",
      :elapsed_time => 14579,
      :description => nil,
      :name => "02/28/10 San Francisco, CA",
      :moving_time => 12748,
      :average_speed => 23260.8064010041,
      :distance => 82369.1,
      :start_date => "2010-02-28T16:31:35Z",
      :average_watts => 175.112,
      :start_date_local => "2010-02-28T08:31:35Z",
      :id => 77563,
      :maximum_speed => 64251.72
    }.each do |property, value| 
      assert result[property] == value, "mismatch on #{property}: #{result[property]} != #{value}"
    end
    
    assert result[:athlete].is_a?(Strava::Member)
    assert result[:athlete].username == "julianbill"
    
    assert result[:bike].is_a?(Strava::Bike)
    assert result[:bike].name == "Serotta Legend Ti"
  end
  
  def test_ride_efforts
    #curl "http://www.strava.com/api/v1/rides/77563/efforts"
    api_result = JSON.parse ride_efforts_json
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/rides/77563/efforts', { :query => {} }).returns(api_result)

    result = @s.ride_efforts(77563)
    
    assert result.is_a?(Array)
    result.each do |effort|
      assert effort.is_a?(Strava::Effort)
    end
    
    assert result.first.segment.is_a?(Strava::Segment)
    assert result.first.segment.name == "Panhandle to GGP"
  end
end
