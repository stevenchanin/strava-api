require 'helper'

class TestStrava < Test::Unit::TestCase
  def expect_error(error, &block)
    begin
      block.call
    rescue error
      assert true
    else
      assert false
    end
  end
  
  ###### Testing Strava::Base
  def setup
    @s = Strava::Base.new
  end
  
  def test_create
    assert @s.is_a?(Strava::Base)
  end
  
  def test_bad_command
    expect_error(Strava::CommandError) { @s.call('clubsx', 'club', {}) }
  end
  
  #TODO: figure out how to stub out Httparty.get so I can test other errors
  
  def test_call_returns_response
    result = @s.call('clubs', 'clubs', {:name => 'X'})

    #TODO: figure out why this fails, as far as I can tell result is an HTTPary::Response...
    #assert result.is_a?(HTTParty::Response)
  end
  
  ###### Testing Strava::Clubs
  #test clubs methods
  def test_clubs_index
    result = @s.clubs('X')
    
    assert result.is_a?(Array)

    result.each do |club|
      assert club.is_a?(Strava::Club)
    end
  end
  
  def test_clubs_index_that_returns_nothing
    result = @s.clubs('X93afadf80833')
    
    assert result.is_a?(Array)
    assert result.empty?
  end

  #SLO Nexus, id = 23
  def test_club_show
    result = @s.club_show(23)
    
    assert result.is_a?(Strava::Club)
    assert result.name == "SLO Nexus"
    assert result.id == 23
    assert result.location == "San Luis Obispo, CA"
    assert result.description == "SLO Nexus brings together people who love to ride bikes, race bikes, and promote bike riding in our community. Our fresh outlook on the local bike scene incorporates support, fun, education, and fitness and is designed to bring together the growing number"
  end
  
  def test_club_show_bad_id
    expect_error(Strava::InvalidResponseError) { @s.club_show(0) }
    
    assert @s.errors.include?("Invalid clubs/0")
  end
  
  def test_club_members
    result = @s.club_members(23)
    
    assert result.is_a?(Array)
    result.each do |member|
      assert member.is_a?(Strava::Member)
    end

    assert result.first.name == "Dan Speirs"
  end
  
  ###### Testing Strava::Rides
  #test ridess methods
  def test_rides_index_no_arguments
    expect_error(Strava::CommandError) { @s.rides }
  end
  
  def test_rides_index_invalid_argument
    expect_error(Strava::CommandError) { @s.rides(:invalid => true) }
  end

  def test_rides_index_by_club
    result = @s.rides(:club_id => 23)
    
    assert result.is_a?(Array)
    
    result.each do |ride|
      assert ride.is_a?(Strava::Ride)
    end
  end

  def test_rides_index_by_athlete
    result = @s.rides(:athlete_id => 779)
    
    assert result.is_a?(Array)
    
    result.each do |ride|
      assert ride.is_a?(Strava::Ride)
    end
  end

  def test_rides_index_by_club_and_athlete
    result = @s.rides(:club_id => 23, :athlete_id => 779)
    
    assert result.is_a?(Array)
    
    result.each do |ride|
      assert ride.is_a?(Strava::Ride)
    end
  end

  def test_rides_index_with_mismatched_club_and_athlete
    expect_error(Strava::InvalidResponseError) { @s.rides(:club_id => 24, :athlete_id => 779) }
    
    assert @s.errors.include?("Invalid clubId")
  end
  
  def test_rides_index_ignores_invalid_parameter
    result = @s.rides(:athlete_id => 779, :xclub_id => 24)
    
    assert result.is_a?(Array)
    
    result.each do |ride|
      assert ride.is_a?(Strava::Ride)
    end
  end
  
  def test_rides_after_start_date
    result = @s.rides(:athlete_id => 779, :start_date => Date.civil(2010,9,21))
    
    assert result.is_a?(Array)
    
    result.each do |ride|
      assert ride.is_a?(Strava::Ride)
      #TODO check that each ride is after 9/21/2010
    end
  end
  
  #SLO Nexus, id = 23
  def test_ride_show
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
      :start_date => Time.parse("2010-02-28T16:31:35Z"),
      :average_watts => 175.112,
      :start_date_local => Time.parse("2010-02-28T08:31:35Z"),
      :id => 77563,
      :maximum_speed => 64251.72
      
      #TODO: handle athlete & bike
    }.each do |property, value| 
      assert result[property] == value
    end
  end
  
  def test_club_show_bad_id
    expect_error(Strava::InvalidResponseError) { @s.club_show(0) }
    
    assert @s.errors.include?("Invalid clubs/0")
  end

  def test_ride_efforts
    result = @s.ride_efforts(77563)
    
    assert result.is_a?(Array)
    result.each do |effort|
      assert effort.is_a?(Strava::Effort)
    end
  end

end
