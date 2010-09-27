require 'helper'
require 'mocha'
require 'json'

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
    Strava::Base.stubs(:get).with('/clubsx', {:query => {}}).raises(Strava::CommandError)

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
    #curl http://www.strava.com/api/v1/clubs?name=X
    api_result = JSON.parse '{"clubs":[{"name":"SLO Nexus","id":23},{"name":"Ex Has Beens That Never Were","id":31},{"name":"Team FeXY","id":150},{"name":"Paris Fixed Gear","id":247}]}'
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/clubs', {:query => {:name => 'X'}}).returns(api_result)

    result = @s.clubs('X')
    
    assert result.is_a?(Array)

    result.each do |club|
      assert club.is_a?(Strava::Club)
    end
  end
  
  def test_clubs_index_that_returns_nothing
    #curl http://www.strava.com/api/v1/clubs?name=X5678i9o90
    api_result = JSON.parse '{"clubs":[]}'
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/clubs', {:query => {:name => 'X93afadf80833'}}).returns(api_result)

    result = @s.clubs('X93afadf80833')
    
    assert result.is_a?(Array)
    assert result.empty?
  end

  #SLO Nexus, id = 23
  def test_club_show
    #curl http://www.strava.com/api/v1/clubs/23
    api_result = JSON.parse '{"club":{"location":"San Luis Obispo, CA","description":"SLO Nexus brings together people who love to ride bikes, race bikes, and promote bike riding in our community. Our fresh outlook on the local bike scene incorporates support, fun, education, and fitness and is designed to bring together the growing number","name":"SLO Nexus","id":23}}'
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/clubs/23', { :query => {} }).returns(api_result)

    result = @s.club_show(23)
    
    assert result.is_a?(Strava::Club)
    assert result.name == "SLO Nexus"
    assert result.id == 23
    assert result.location == "San Luis Obispo, CA"
    assert result.description == "SLO Nexus brings together people who love to ride bikes, race bikes, and promote bike riding in our community. Our fresh outlook on the local bike scene incorporates support, fun, education, and fitness and is designed to bring together the growing number"
  end
  
  def test_club_show_bad_id
    #curl http://www.strava.com/api/v1/clubs/0
    api_result = JSON.parse '{"error":"Invalid clubs/0"}'
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/clubs/0', { :query => {} }).returns(api_result)
    
    expect_error(Strava::InvalidResponseError) { @s.club_show(0) }
    
    assert @s.errors.include?("Invalid clubs/0")
  end
  
  def test_club_members
    #curl http://www.strava.com/api/v1/clubs/23/members
    api_result = JSON.parse '{"club":{"name":"SLO Nexus","id":23},"members":[{"name":"Dan Speirs","id":569},{"name":"Steve Sharp","id":779},{"name":"Jesse Englert","id":5747},{"name":"Garrett Otto","id":6006},{"name":"Ken Kienow","id":4944},{"name":"Brad Buxton","id":5984}]}'
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/clubs/23/members', { :query => {} }).returns(api_result)

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
    #curl http://www.strava.com/api/v1/rides?clubId=23
    api_result = JSON.parse '{"rides":[{"name":"from SVRMC","id":191846},{"name":"Highland Hill Repeats x 4","id":191847},{"name":"from SVRMC","id":190933},{"name":"Lunch TT Ride","id":190934},{"name":"to French & Back Warm-up","id":190935},{"name":"Parkfield Classic XC","id":192353},{"name":"to SVRMC","id":190932},{"name":"Perfumo","id":190406},{"name":"from SVRMC + Flat","id":190402},{"name":"to SVRMC","id":190401},{"name":"Cerro San Luis Lap","id":192352},{"name":"Perfumo Repeats x2 - 09/23/2010 San Luis Obispo, CA","id":189813},{"name":"Pick up Sydney from School","id":191780},{"name":"Black Hill/MDO/Perfumo","id":189654},{"name":"Perfumo","id":189578},{"name":"from SVRMC","id":189204},{"name":"to SVRMC","id":189203},{"name":"Tiffany Loop and Johnson Ranch","id":189544},{"name":"from SVRMC","id":188865},{"name":"Noon Hammer Ride","id":188866},{"name":"09/21/2010 San Luis Obispo, CA","id":188671},{"name":"Noon hammer ride","id":188591},{"name":"to SVRMC","id":188864},{"name":"from SVRMC","id":188091},{"name":"Up 227 then rode with Todd to AG 09/20/10 San Luis Obispo, CA","id":187942},{"name":"See","id":187875},{"name":"to SVRMC","id":188092},{"name":"Perfumo Punishment","id":187072},{"name":"Road ride with Colin - 09/19/10 Arroyo Grande, CA","id":187052},{"name":"Mtn Bike with Colin & Duncan - Johnson Loop - 09/19/10 San Luis Obispo, CA","id":187051},{"name":"Tiffany Loop","id":186702},{"name":"MDO with Dad","id":185910},{"name":"Upper Lopez Canyon","id":185894},{"name":"See loop","id":184713},{"name":"from SVRMC","id":184615},{"name":"to SVRMC","id":184616},{"name":"Perfumo Recovery","id":183855},{"name":"to SVRMC","id":183854},{"name":"Turri Loop","id":186704},{"name":"from SVRMC","id":183234},{"name":"Hammer Ride - 09/14/10 San Luis Obispo, CA","id":183230},{"name":"Noon Hammer Ride","id":183233},{"name":"Noon hammer ride","id":183000},{"name":"to SVRMC","id":183235},{"name":"Irish Hills","id":186705},{"name":"from SVRMC","id":182825},{"name":"Lopez then up 227 - 09/13/10 San Luis Obispo, CA","id":182763},{"name":"to SVRMC","id":182824},{"name":"recovery","id":182462},{"name":"Tiffany Loop","id":186703}]}'
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
    api_result = JSON.parse '{"rides":[{"name":"from SVRMC","id":191846},{"name":"Highland Hill Repeats x 4","id":191847},{"name":"from SVRMC","id":190933},{"name":"Lunch TT Ride","id":190934},{"name":"to French & Back Warm-up","id":190935},{"name":"to SVRMC","id":190932},{"name":"from SVRMC + Flat","id":190402},{"name":"to SVRMC","id":190401},{"name":"Pick up Sydney from School","id":191780},{"name":"Black Hill/MDO/Perfumo","id":189654},{"name":"from SVRMC","id":189204},{"name":"to SVRMC","id":189203},{"name":"from SVRMC","id":188865},{"name":"Noon Hammer Ride","id":188866},{"name":"to SVRMC","id":188864},{"name":"from SVRMC","id":188091},{"name":"to SVRMC","id":188092},{"name":"Perfumo Punishment","id":187072},{"name":"Upper Lopez Canyon","id":185894},{"name":"from SVRMC","id":184615},{"name":"to SVRMC","id":184616},{"name":"Perfumo Recovery","id":183855},{"name":"to SVRMC","id":183854},{"name":"from SVRMC","id":183234},{"name":"Noon Hammer Ride","id":183233},{"name":"to SVRMC","id":183235},{"name":"from SVRMC","id":182825},{"name":"to SVRMC","id":182824},{"name":"Fire Lookout/Hwy 267 climb","id":182280},{"name":"ride to beach with Jill","id":181240},{"name":"Mt. Rose/Fire Lookout","id":182281},{"name":"Tahoe City-Truckee-Kings Beach","id":180876},{"name":"spin with Jill","id":180605},{"name":"from SVRMC","id":179483},{"name":"to SVRMC","id":179482},{"name":"from SVRMC","id":178806},{"name":"Noon Hammer Ride","id":178808},{"name":"to SVRMC","id":178807},{"name":"from SVRMC","id":177056},{"name":"Lunch Ride Highland Hill X 4","id":177057},{"name":"to SVRMC","id":177058},{"name":"from SVRMC","id":176133},{"name":"Lunch TT Ride","id":176134},{"name":"to SVRMC","id":176132},{"name":"from SVRMC","id":175349},{"name":"Lunch TT Ride","id":175350},{"name":"to SVRMC","id":175351},{"name":"spin home ","id":174393},{"name":"Highland Hill Repeats X 7","id":173830},{"name":"to SVRMC","id":173829}]}'
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
    api_result = JSON.parse '{"rides":[{"name":"from SVRMC","id":191846},{"name":"Highland Hill Repeats x 4","id":191847},{"name":"from SVRMC","id":190933},{"name":"Lunch TT Ride","id":190934},{"name":"to French & Back Warm-up","id":190935},{"name":"to SVRMC","id":190932},{"name":"from SVRMC + Flat","id":190402},{"name":"to SVRMC","id":190401},{"name":"Pick up Sydney from School","id":191780},{"name":"Black Hill/MDO/Perfumo","id":189654},{"name":"from SVRMC","id":189204},{"name":"to SVRMC","id":189203},{"name":"from SVRMC","id":188865},{"name":"Noon Hammer Ride","id":188866},{"name":"to SVRMC","id":188864},{"name":"from SVRMC","id":188091},{"name":"to SVRMC","id":188092},{"name":"Perfumo Punishment","id":187072},{"name":"Upper Lopez Canyon","id":185894},{"name":"from SVRMC","id":184615},{"name":"to SVRMC","id":184616},{"name":"Perfumo Recovery","id":183855},{"name":"to SVRMC","id":183854},{"name":"from SVRMC","id":183234},{"name":"Noon Hammer Ride","id":183233},{"name":"to SVRMC","id":183235},{"name":"from SVRMC","id":182825},{"name":"to SVRMC","id":182824},{"name":"Fire Lookout/Hwy 267 climb","id":182280},{"name":"ride to beach with Jill","id":181240},{"name":"Mt. Rose/Fire Lookout","id":182281},{"name":"Tahoe City-Truckee-Kings Beach","id":180876},{"name":"spin with Jill","id":180605},{"name":"from SVRMC","id":179483},{"name":"to SVRMC","id":179482},{"name":"from SVRMC","id":178806},{"name":"Noon Hammer Ride","id":178808},{"name":"to SVRMC","id":178807},{"name":"from SVRMC","id":177056},{"name":"Lunch Ride Highland Hill X 4","id":177057},{"name":"to SVRMC","id":177058},{"name":"from SVRMC","id":176133},{"name":"Lunch TT Ride","id":176134},{"name":"to SVRMC","id":176132},{"name":"from SVRMC","id":175349},{"name":"Lunch TT Ride","id":175350},{"name":"to SVRMC","id":175351},{"name":"spin home ","id":174393},{"name":"Highland Hill Repeats X 7","id":173830},{"name":"to SVRMC","id":173829}]}'
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
    api_result = JSON.parse '{"rides":[{"name":"from SVRMC","id":191846},{"name":"Highland Hill Repeats x 4","id":191847},{"name":"from SVRMC","id":190933},{"name":"Lunch TT Ride","id":190934},{"name":"to French & Back Warm-up","id":190935},{"name":"to SVRMC","id":190932},{"name":"from SVRMC + Flat","id":190402},{"name":"to SVRMC","id":190401},{"name":"Pick up Sydney from School","id":191780},{"name":"Black Hill/MDO/Perfumo","id":189654},{"name":"from SVRMC","id":189204},{"name":"to SVRMC","id":189203},{"name":"from SVRMC","id":188865},{"name":"Noon Hammer Ride","id":188866},{"name":"to SVRMC","id":188864},{"name":"from SVRMC","id":188091},{"name":"to SVRMC","id":188092},{"name":"Perfumo Punishment","id":187072},{"name":"Upper Lopez Canyon","id":185894},{"name":"from SVRMC","id":184615},{"name":"to SVRMC","id":184616},{"name":"Perfumo Recovery","id":183855},{"name":"to SVRMC","id":183854},{"name":"from SVRMC","id":183234},{"name":"Noon Hammer Ride","id":183233},{"name":"to SVRMC","id":183235},{"name":"from SVRMC","id":182825},{"name":"to SVRMC","id":182824},{"name":"Fire Lookout/Hwy 267 climb","id":182280},{"name":"ride to beach with Jill","id":181240},{"name":"Mt. Rose/Fire Lookout","id":182281},{"name":"Tahoe City-Truckee-Kings Beach","id":180876},{"name":"spin with Jill","id":180605},{"name":"from SVRMC","id":179483},{"name":"to SVRMC","id":179482},{"name":"from SVRMC","id":178806},{"name":"Noon Hammer Ride","id":178808},{"name":"to SVRMC","id":178807},{"name":"from SVRMC","id":177056},{"name":"Lunch Ride Highland Hill X 4","id":177057},{"name":"to SVRMC","id":177058},{"name":"from SVRMC","id":176133},{"name":"Lunch TT Ride","id":176134},{"name":"to SVRMC","id":176132},{"name":"from SVRMC","id":175349},{"name":"Lunch TT Ride","id":175350},{"name":"to SVRMC","id":175351},{"name":"spin home ","id":174393},{"name":"Highland Hill Repeats X 7","id":173830},{"name":"to SVRMC","id":173829}]}'
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
    api_result = JSON.parse '{"rides":[{"name":"from SVRMC","id":191846},{"name":"Highland Hill Repeats x 4","id":191847},{"name":"from SVRMC","id":190933},{"name":"Lunch TT Ride","id":190934},{"name":"to French & Back Warm-up","id":190935},{"name":"to SVRMC","id":190932},{"name":"from SVRMC + Flat","id":190402},{"name":"to SVRMC","id":190401},{"name":"Pick up Sydney from School","id":191780},{"name":"Black Hill/MDO/Perfumo","id":189654},{"name":"from SVRMC","id":189204},{"name":"to SVRMC","id":189203},{"name":"from SVRMC","id":188865},{"name":"Noon Hammer Ride","id":188866},{"name":"to SVRMC","id":188864}]}'
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/rides', { :query => {'athleteId' => 779, 'startDate' => Date.civil(2010,9,21)} }).returns(api_result)

    result = @s.rides(:athlete_id => 779, :start_date => Date.civil(2010,9,21))
    
    assert result.is_a?(Array)
    
    result.each do |ride|
      assert ride.is_a?(Strava::Ride)
      #TODO check that each ride is after 9/21/2010
    end
  end
  
  def test_ride_show
    #curl "http://www.strava.com/api/v1/rides/77563"
    api_result = JSON.parse '{"ride":{"averageSpeed":23260.8064010041,"location":"San Francisco, CA","startDate":"2010-02-28T16:31:35Z","description":null,"averageWatts":175.112,"name":"02/28/10 San Francisco, CA","startDateLocal":"2010-02-28T08:31:35Z","maximumSpeed":64251.72,"timeZoneOffset":-8.0,"athlete":{"username":"julianbill","name":"Julian Bill","id":1139},"elevationGain":1441.02,"distance":82369.1,"elapsedTime":14579,"bike":{"name":"Serotta Legend Ti","id":903},"id":77563,"movingTime":12748}}'
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
    api_result = JSON.parse '{"ride":{"name":"02/28/10 San Francisco, CA","id":77563},"efforts":[{"elapsed_time":209,"segment":{"name":"Panhandle to GGP","id":623323},"id":2231990},{"elapsed_time":63,"segment":{"name":"Conservatory of Flowers Hill","id":626358},"id":2543643},{"elapsed_time":409,"segment":{"name":"GGB Northbound","id":616515},"id":1523485},{"elapsed_time":470,"segment":{"name":"Bridgeway Vigilance Northbound","id":623072},"id":2201113},{"elapsed_time":126,"segment":{"name":"Mike\'s Bikes Sprint","id":626575},"id":2605695},{"elapsed_time":317,"segment":{"name":"Miller Ave TT","id":613995},"id":1324431},{"elapsed_time":776,"segment":{"name":"Brad\'s Climb (formerly Jim\'s Climb) (MV to 4Cs)","id":361375},"id":688442},{"elapsed_time":1185,"segment":{"name":"Mill Valley to Panoramic via Marion Ave","id":718},"id":688443},{"elapsed_time":2148,"segment":{"name":"Mill Valley to Pantoll","id":622149},"id":2078609},{"elapsed_time":1268,"segment":{"name":"4 Corners to Bootjack","id":609323},"id":840745},{"elapsed_time":1498,"segment":{"name":"4 Corners to Pantoll Station","id":625065},"id":2419895},{"elapsed_time":598,"segment":{"name":"Panoramic to Pan Toll","id":156},"id":688432},{"elapsed_time":547,"segment":{"name":"Stinson Beach Descent","id":617195},"id":1594150},{"elapsed_time":471,"segment":{"name":"Stinson Climb 1, south ","id":157},"id":688433},{"elapsed_time":1582,"segment":{"name":"Stinson Beach to Muir Beach","id":615929},"id":1469576},{"elapsed_time":1237,"segment":{"name":"Steep Ravine to Pelican Inn","id":618085},"id":1670144},{"elapsed_time":369,"segment":{"name":"Highway 1 South from Cold Stream","id":719},"id":688439},{"elapsed_time":656,"segment":{"name":"Muir Beach East","id":158},"id":688434},{"elapsed_time":240,"segment":{"name":"Panoramic to Mill Valley descent","id":611080},"id":1011931},{"elapsed_time":125,"segment":{"name":"Thread the Needle","id":616316},"id":1499338},{"elapsed_time":574,"segment":{"name":"Bridgeway Vigilance","id":614103},"id":1332656},{"elapsed_time":512,"segment":{"name":"Sausalito to GGB Climb","id":612804},"id":1214916},{"elapsed_time":407,"segment":{"name":"Sausalito to GGB","id":132513},"id":688436},{"elapsed_time":399,"segment":{"name":"GGB Southbound","id":597755},"id":771451},{"elapsed_time":342,"segment":{"name":"Presidio Wiggle","id":609096},"id":819402},{"elapsed_time":283,"segment":{"name":"Extended Presidio Sprint ","id":623484},"id":2259387},{"elapsed_time":164,"segment":{"name":"Presidio Sprint","id":318917},"id":688440},{"elapsed_time":86,"segment":{"name":"Oak Street (Schrader to Baker)","id":611238},"id":1032310}]}'
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
