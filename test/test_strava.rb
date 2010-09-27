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

  def test_segments_index
    #curl http://www.strava.com/api/v1/segments?name=hawk%20hill
    api_result = JSON.parse '{"segments":[{"name":"Hawk Hill Saddle","id":99243},{"name":"Hawk Hill","id":229781},{"name":"Hawk Hill from Bunker Road","id":229783},{"name":"Ham Hawk Hill | PD","id":243831},{"name":"Hawk Hill from Fort Baker","id":461025},{"name":"Hawk Hill from Sausalito","id":522551},{"name":"Hawk Hill Backside Descent","id":589138},{"name":"Backside Hawk Hill Climb","id":615706},{"name":"Hawk Hill Saddle from Sausalito","id":617665},{"name":"Hawk Hill Saddle from Ft Baker","id":619494}]}'
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/segments', {:query => {:name => 'Hawk Hill'}}).returns(api_result)

    result = @s.segments('Hawk Hill')
    
    assert result.is_a?(Array)

    result.each do |segment|
      assert segment.is_a?(Strava::Segment)
    end
  end

  def test_segments_index_that_returns_nothing
    #curl http://www.strava.com/api/v1/segments?name=hawk%20hillxxxy
    api_result = JSON.parse '{"segments":[]}'
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/segments', {:query => {:name => 'Hawk Hill98xcasdf'}}).returns(api_result)

    result = @s.segments('Hawk Hill98xcasdf')
    
    assert result.is_a?(Array)
    assert result.empty?
  end

  def test_segment_show
    #rl http://www.strava.com/api/v1/segments/99243
    api_result = JSON.parse '{"segment":{"averageGrade":4.63873,"climbCategory":"4","name":"Hawk Hill Saddle","elevationGain":76.553,"distance":1771.88,"elevationHigh":172.694,"id":99243,"elevationLow":90.5013}}'
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/segments/99243', { :query => {} }).returns(api_result)

    result = @s.segment_show(99243)
    
    assert result.is_a?(Strava::Segment)
    assert result.name == "Hawk Hill Saddle"
    assert result.id == 99243
    assert result.average_grade == 4.63873
    assert result.climb_category == "4"
    assert result.elevation_gain == 76.553
    assert result.distance == 1771.88
    assert result.elevation_high == 172.694
    assert result.elevation_low == 90.5013
  end
  
  def test_segment_efforts_with_invalid_id
    api_result = JSON.parse '{"error":"Invalid segments/0"}'
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/segments/0/efforts', {:query => {}}).returns(api_result)

    expect_error(Strava::InvalidResponseError) { @s.segment_efforts(0) }
    
    assert @s.errors.include?("Invalid segments/0")
  end
  
  def test_segment_efforts_index
    #curl http://www.strava.com/api/v1/segments/99243/efforts
    #note: cut some out because the response was so long
    api_result = JSON.parse '{"efforts":[{"startDate":"2010-04-29T13:59:24Z","startDateLocal":"2010-04-29T06:59:24Z","activityId":95206,"timeZoneOffset":-8.0,"athlete":{"username":"davidbelden","name":"David Belden","id":8},"elapsedTime":247,"id":911835},{"startDate":"2010-01-28T15:04:59Z","startDateLocal":"2010-01-28T07:04:59Z","activityId":67051,"timeZoneOffset":-8.0,"athlete":{"username":"jsimons","name":"Jay Simons","id":1377},"elapsedTime":250,"id":567839},{"startDate":"2010-01-31T18:35:51Z","startDateLocal":"2010-01-31T10:35:51Z","activityId":68093,"timeZoneOffset":-8.0,"athlete":{"username":"dhaynes","name":"Derek Haynes","id":1781},"elapsedTime":261,"id":579787}],"segment":{"name":"Hawk Hill Saddle","id":99243}}'
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/segments/99243/efforts', {:query => {}}).returns(api_result)

    result = @s.segment_efforts(99243)
    
    assert result.is_a?(Array)
    
    result.each do |effort|
      assert effort.is_a?(Strava::Effort)
    end
  end

  def test_segment_efforts_index_by_athlete_id
    #curl http://www.strava.com/api/v1/segments/99243/efforts?athleteId=1377
    api_result = JSON.parse '{"efforts":[{"startDate":"2010-01-28T15:04:59Z","startDateLocal":"2010-01-28T07:04:59Z","activityId":67051,"timeZoneOffset":-8.0,"athlete":{"username":"jsimons","name":"Jay Simons","id":1377},"elapsedTime":250,"id":567839},{"startDate":"2010-02-04T15:02:29Z","startDateLocal":"2010-02-04T07:02:29Z","activityId":69675,"timeZoneOffset":-8.0,"athlete":{"username":"jsimons","name":"Jay Simons","id":1377},"elapsedTime":264,"id":597043},{"startDate":"2010-05-11T13:54:04Z","startDateLocal":"2010-05-11T06:54:04Z","activityId":100392,"timeZoneOffset":-8.0,"athlete":{"username":"jsimons","name":"Jay Simons","id":1377},"elapsedTime":269,"id":983029},{"startDate":"2010-07-08T13:54:40Z","startDateLocal":"2010-07-08T06:54:40Z","activityId":135052,"timeZoneOffset":-8.0,"athlete":{"username":"jsimons","name":"Jay Simons","id":1377},"elapsedTime":271,"id":1591612},{"startDate":"2010-01-15T15:08:03Z","startDateLocal":"2010-01-15T07:08:03Z","activityId":62521,"timeZoneOffset":-8.0,"athlete":{"username":"jsimons","name":"Jay Simons","id":1377},"elapsedTime":277,"id":517053},{"startDate":"2010-01-27T15:05:46Z","startDateLocal":"2010-01-27T07:05:46Z","activityId":66977,"timeZoneOffset":-8.0,"athlete":{"username":"jsimons","name":"Jay Simons","id":1377},"elapsedTime":280,"id":567121},{"startDate":"2010-03-31T00:32:18Z","startDateLocal":"2010-03-30T17:32:18Z","activityId":85948,"timeZoneOffset":-8.0,"athlete":{"username":"jsimons","name":"Jay Simons","id":1377},"elapsedTime":285,"id":792315},{"startDate":"2010-01-30T23:15:05Z","startDateLocal":"2010-01-30T15:15:05Z","activityId":67623,"timeZoneOffset":-8.0,"athlete":{"username":"jsimons","name":"Jay Simons","id":1377},"elapsedTime":290,"id":574957},{"startDate":"2010-04-10T20:45:31Z","startDateLocal":"2010-04-10T13:45:31Z","activityId":88363,"timeZoneOffset":-8.0,"athlete":{"username":"jsimons","name":"Jay Simons","id":1377},"elapsedTime":290,"id":831915},{"startDate":"2010-04-13T13:53:55Z","startDateLocal":"2010-04-13T06:53:55Z","activityId":96689,"timeZoneOffset":-8.0,"athlete":{"username":"jsimons","name":"Jay Simons","id":1377},"elapsedTime":291,"id":931209},{"startDate":"2010-03-30T14:08:07Z","startDateLocal":"2010-03-30T07:08:07Z","activityId":85949,"timeZoneOffset":-8.0,"athlete":{"username":"jsimons","name":"Jay Simons","id":1377},"elapsedTime":292,"id":792330},{"startDate":"2010-01-16T19:51:04Z","startDateLocal":"2010-01-16T11:51:04Z","activityId":62823,"timeZoneOffset":-8.0,"athlete":{"username":"jsimons","name":"Jay Simons","id":1377},"elapsedTime":296,"id":519899},{"startDate":"2010-01-13T15:05:47Z","startDateLocal":"2010-01-13T07:05:47Z","activityId":62517,"timeZoneOffset":-8.0,"athlete":{"username":"jsimons","name":"Jay Simons","id":1377},"elapsedTime":309,"id":517035},{"startDate":"2010-02-10T15:03:11Z","startDateLocal":"2010-02-10T07:03:11Z","activityId":73763,"timeZoneOffset":-8.0,"athlete":{"username":"jsimons","name":"Jay Simons","id":1377},"elapsedTime":314,"id":644917},{"startDate":"2010-07-30T02:35:46Z","startDateLocal":"2010-07-29T19:35:46Z","activityId":147817,"timeZoneOffset":-8.0,"athlete":{"username":"jsimons","name":"Jay Simons","id":1377},"elapsedTime":319,"id":1847072},{"startDate":"2010-02-08T01:09:02Z","startDateLocal":"2010-02-07T17:09:02Z","activityId":73761,"timeZoneOffset":-8.0,"athlete":{"username":"jsimons","name":"Jay Simons","id":1377},"elapsedTime":326,"id":644899},{"startDate":"2010-05-09T01:38:55Z","startDateLocal":"2010-05-08T18:38:55Z","activityId":99414,"timeZoneOffset":-8.0,"athlete":{"username":"jsimons","name":"Jay Simons","id":1377},"elapsedTime":326,"id":967659}],"segment":{"name":"Hawk Hill Saddle","id":99243}}'
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/segments/99243/efforts', {:query => {'athleteId' => 1377}}).returns(api_result)

    result = @s.segment_efforts(99243, {:athlete_id => 1377})
    
    assert result.is_a?(Array)
    
    result.each do |effort|
      assert effort.is_a?(Strava::Effort)
      assert effort.athlete.id == 1377, "#{effort.athlete.id} != 1377"
    end
  end

  def test_segment_efforts_index_by_athlete_id_and_start_date
    #curl "http://www.strava.com/api/v1/segments/99243/efforts?athleteId=1377&startDate=2010-07-01"
    api_result = JSON.parse '{"efforts":[{"startDate":"2010-07-08T13:54:40Z","startDateLocal":"2010-07-08T06:54:40Z","activityId":135052,"timeZoneOffset":-8.0,"athlete":{"username":"jsimons","name":"Jay Simons","id":1377},"elapsedTime":271,"id":1591612},{"startDate":"2010-07-30T02:35:46Z","startDateLocal":"2010-07-29T19:35:46Z","activityId":147817,"timeZoneOffset":-8.0,"athlete":{"username":"jsimons","name":"Jay Simons","id":1377},"elapsedTime":319,"id":1847072}],"segment":{"name":"Hawk Hill Saddle","id":99243}}'
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/segments/99243/efforts', {:query => {'athleteId' => 1377, 'startDate' => Date.civil(2010,7,1)}}).returns(api_result)

    result = @s.segment_efforts(99243, {:athlete_id => 1377, :start_date => Date.civil(2010,7,1)})
    
    assert result.is_a?(Array)
    
    result.each do |effort|
      assert effort.is_a?(Strava::Effort)
      assert effort.athlete.id == 1377, "#{effort.athlete.id} != 1377"

      #works with the real api call, but the stub that is just JSON parsing isn't converting times to Time objects
      #assert effort.start_date >= Time.utc(2010,7,1), "#{effort.start_date} < 2010-7-1"
    end
  end

  def test_segment_efforts_index_by_club_id_and_best
    #using test data for club 15
    #curl http://www.strava.com/api/v1/segments/99243/efforts?clubId=15&best=true
    api_result = JSON.parse '{"efforts":[{"startDate":"2010-04-29T13:59:24Z","startDateLocal":"2010-04-29T06:59:24Z","activityId":95206,"timeZoneOffset":-8.0,"athlete":{"username":"davidbelden","name":"David Belden","id":8},"elapsedTime":247,"id":911835},{"startDate":"2010-01-28T15:04:59Z","startDateLocal":"2010-01-28T07:04:59Z","activityId":67051,"timeZoneOffset":-8.0,"athlete":{"username":"jsimons","name":"Jay Simons","id":1377},"elapsedTime":250,"id":567839},{"startDate":"2010-01-31T18:35:51Z","startDateLocal":"2010-01-31T10:35:51Z","activityId":68093,"timeZoneOffset":-8.0,"athlete":{"username":"dhaynes","name":"Derek Haynes","id":1781},"elapsedTime":261,"id":579787},{"startDate":"2009-11-05T18:25:24Z","startDateLocal":"2009-11-05T10:25:24Z","activityId":64013,"timeZoneOffset":-8.0,"athlete":{"username":"jberkman","name":"jacob berkman","id":3005},"elapsedTime":275,"id":533823},{"startDate":"2010-07-01T13:53:26Z","startDateLocal":"2010-07-01T06:53:26Z","activityId":128896,"timeZoneOffset":-8.0,"athlete":{"username":"vitalyg","name":"Vitaly Gashpar","id":4488},"elapsedTime":282,"id":1463618},{"startDate":"2010-06-13T00:56:07Z","startDateLocal":"2010-06-12T17:56:07Z","activityId":118803,"timeZoneOffset":-8.0,"athlete":{"username":"jhudson","name":"Jared Hudson","id":1215},"elapsedTime":283,"id":1297738},{"startDate":"2009-09-04T02:27:14Z","startDateLocal":"2009-09-03T18:27:14Z","activityId":33479,"timeZoneOffset":-8.0,"athlete":{"username":"ykawase","name":"T. Joe Mulvaney","id":1107},"elapsedTime":284,"id":139887},{"startDate":"2010-06-17T13:54:17Z","startDateLocal":"2010-06-17T06:54:17Z","activityId":120897,"timeZoneOffset":-8.0,"athlete":{"username":"matth","name":"Matt Hough","id":4542},"elapsedTime":286,"id":1336905},{"startDate":"2010-06-08T13:55:08Z","startDateLocal":"2010-06-08T06:55:08Z","activityId":115701,"timeZoneOffset":-8.0,"athlete":{"username":"jonringer","name":"Jon Ringer","id":4604},"elapsedTime":287,"id":1245196},{"startDate":"2010-04-13T13:53:33Z","startDateLocal":"2010-04-13T06:53:33Z","activityId":88677,"timeZoneOffset":-8.0,"athlete":{"username":"danv","name":"Dan Vigil","id":1167},"elapsedTime":291,"id":835674},{"startDate":"2010-03-30T14:08:06Z","startDateLocal":"2010-03-30T07:08:06Z","activityId":85754,"timeZoneOffset":-8.0,"athlete":{"username":"mgaiman","name":"Michael Gaiman","id":721},"elapsedTime":294,"id":790228},{"startDate":"2010-06-12T00:06:18Z","startDateLocal":"2010-06-11T17:06:18Z","activityId":118354,"timeZoneOffset":-8.0,"athlete":{"username":"jherrick","name":"Jason Herrick","id":1665},"elapsedTime":294,"id":1290745},{"startDate":"2009-11-29T22:13:26Z","startDateLocal":"2009-11-29T14:13:26Z","activityId":52093,"timeZoneOffset":-8.0,"athlete":{"username":"jblohm","name":"Joern Blohm","id":1723},"elapsedTime":296,"id":416889},{"startDate":"2010-01-28T15:04:48Z","startDateLocal":"2010-01-28T07:04:48Z","activityId":67047,"timeZoneOffset":-8.0,"athlete":{"username":"pd","name":"Peter Durham","id":45},"elapsedTime":298,"id":567793},{"startDate":"2010-03-05T17:40:47Z","startDateLocal":"2010-03-05T09:40:47Z","activityId":78672,"timeZoneOffset":-8.0,"athlete":{"username":"cb","name":"Carl B","id":1889},"elapsedTime":298,"id":699178},{"startDate":"2010-07-02T02:22:42Z","startDateLocal":"2010-07-01T19:22:42Z","activityId":129698,"timeZoneOffset":-8.0,"athlete":{"username":"bprescott","name":"Bruce Prescott","id":2061},"elapsedTime":310,"id":1478082},{"startDate":"2009-09-04T02:27:17Z","startDateLocal":"2009-09-03T18:27:17Z","activityId":36895,"timeZoneOffset":-8.0,"athlete":{"username":"ycolin","name":"Youenn Colin","id":1127},"elapsedTime":312,"id":258717},{"startDate":"2010-04-18T18:54:36Z","startDateLocal":"2010-04-18T11:54:36Z","activityId":90940,"timeZoneOffset":-8.0,"athlete":{"username":"tbrady","name":"Travis Brady","id":1607},"elapsedTime":312,"id":861754},{"startDate":"2009-11-19T15:05:14Z","startDateLocal":"2009-11-19T07:05:14Z","activityId":51461,"timeZoneOffset":-8.0,"athlete":{"username":"valko","name":"Andrew Valko","id":787},"elapsedTime":315,"id":409757},{"startDate":"2010-05-04T13:53:40Z","startDateLocal":"2010-05-04T06:53:40Z","activityId":100932,"timeZoneOffset":-8.0,"athlete":{"username":"qmecke","name":"Quintin Mecke","id":1529},"elapsedTime":315,"id":990554},{"startDate":"2010-06-26T16:51:41Z","startDateLocal":"2010-06-26T09:51:41Z","activityId":125957,"timeZoneOffset":-8.0,"athlete":{"username":"joemulvaney","name":"Joe Mulvaney","id":1487},"elapsedTime":316,"id":1417247},{"startDate":"2010-07-02T02:22:41Z","startDateLocal":"2010-07-01T19:22:41Z","activityId":129495,"timeZoneOffset":-8.0,"athlete":{"username":"zach","name":"Zach Bass","id":1055},"elapsedTime":319,"id":1474299},{"startDate":"2009-11-29T18:25:23Z","startDateLocal":"2009-11-29T10:25:23Z","activityId":51759,"timeZoneOffset":-8.0,"athlete":{"username":"huphtur","name":"M Appelman","id":1157},"elapsedTime":322,"id":413623},{"startDate":"2010-01-21T00:59:42Z","startDateLocal":"2010-01-20T16:59:42Z","activityId":64435,"timeZoneOffset":-8.0,"athlete":{"username":"eugenekim","name":"Eugene Kim","id":1213},"elapsedTime":322,"id":539059},{"startDate":"2009-08-20T14:02:39Z","startDateLocal":"2009-08-20T06:02:39Z","activityId":30369,"timeZoneOffset":-8.0,"athlete":{"username":"bkuczynski","name":"Brian Kuczynski","id":619},"elapsedTime":323,"id":111417},{"startDate":"2010-06-20T16:07:54Z","startDateLocal":"2010-06-20T09:07:54Z","activityId":122312,"timeZoneOffset":-8.0,"athlete":{"username":"jwells","name":"Jason Wells","id":1219},"elapsedTime":324,"id":1358461},{"startDate":"2010-03-31T00:32:19Z","startDateLocal":"2010-03-30T17:32:19Z","activityId":85839,"timeZoneOffset":-8.0,"athlete":{"username":"danno","name":"Dan Oehlberg","id":401},"elapsedTime":326,"id":791136},{"startDate":"2009-10-07T14:02:40Z","startDateLocal":"2009-10-07T06:02:40Z","activityId":40777,"timeZoneOffset":-8.0,"athlete":{"username":"tc","name":"Travis Crawford","id":723},"elapsedTime":329,"id":298897},{"startDate":"2010-04-07T01:20:36Z","startDateLocal":"2010-04-06T18:20:36Z","activityId":87672,"timeZoneOffset":-8.0,"athlete":{"username":"eneedham","name":"Erik Needham","id":4538},"elapsedTime":330,"id":818067},{"startDate":"2010-07-01T01:00:12Z","startDateLocal":"2010-06-30T18:00:12Z","activityId":128662,"timeZoneOffset":-8.0,"athlete":{"username":"nates","name":"Nate S","id":4285},"elapsedTime":330,"id":1460693},{"startDate":"2010-05-21T15:12:58Z","startDateLocal":"2010-05-21T08:12:58Z","activityId":104830,"timeZoneOffset":-8.0,"athlete":{"username":"kcowling","name":"Keith Cowling","id":3926},"elapsedTime":336,"id":1057536},{"startDate":"2010-02-17T23:28:03Z","startDateLocal":"2010-02-17T15:28:03Z","activityId":75154,"timeZoneOffset":-8.0,"athlete":{"username":"jonathanhunt","name":"Jonathan Hunt","id":2329},"elapsedTime":337,"id":662152},{"startDate":"2009-09-04T02:27:13Z","startDateLocal":"2009-09-03T18:27:13Z","activityId":33501,"timeZoneOffset":-8.0,"athlete":{"username":"greg101","name":"Gregory Allen","id":1143},"elapsedTime":340,"id":140065},{"startDate":"2009-11-17T18:49:29Z","startDateLocal":"2009-11-17T10:49:29Z","activityId":63725,"timeZoneOffset":-8.0,"athlete":{"username":"toshok","name":"Chris Toshok","id":3007},"elapsedTime":340,"id":529631},{"startDate":"2010-03-31T00:32:18Z","startDateLocal":"2010-03-30T17:32:18Z","activityId":86079,"timeZoneOffset":-8.0,"athlete":{"username":"tsantaniello","name":"T. Santaniello","id":3793},"elapsedTime":340,"id":794145},{"startDate":"2009-02-02T23:12:09Z","startDateLocal":"2009-02-02T15:12:09Z","activityId":33075,"timeZoneOffset":-8.0,"athlete":{"username":"double_d","name":"Dylan DiBona","id":1205},"elapsedTime":341,"id":136143},{"startDate":"2010-07-08T13:54:42Z","startDateLocal":"2010-07-08T06:54:42Z","activityId":133181,"timeZoneOffset":-8.0,"athlete":{"username":"spatlove","name":"S. Patlove (recumbent)","id":3875},"elapsedTime":341,"id":1547704},{"startDate":"2010-06-30T01:53:43Z","startDateLocal":"2010-06-29T18:53:43Z","activityId":128204,"timeZoneOffset":-8.0,"athlete":{"username":"mikwat","name":"Michael Watts","id":1163},"elapsedTime":345,"id":1451412},{"startDate":"2010-08-18T14:29:07Z","startDateLocal":"2010-08-18T07:29:07Z","activityId":160681,"timeZoneOffset":-8.0,"athlete":{"username":"mkahn","name":"Mark Kahn","id":4526},"elapsedTime":346,"id":2095970},{"startDate":"2010-07-08T13:54:41Z","startDateLocal":"2010-07-08T06:54:41Z","activityId":133134,"timeZoneOffset":-8.0,"athlete":{"username":"kolofsen","name":"Ken Olofsen","id":2921},"elapsedTime":348,"id":1546484},{"startDate":"2010-07-23T02:39:25Z","startDateLocal":"2010-07-22T19:39:25Z","activityId":144477,"timeZoneOffset":-8.0,"athlete":{"username":"gferrando","name":"G. Ferrando","id":1633},"elapsedTime":350,"id":1772964},{"startDate":"2009-11-15T17:58:12Z","startDateLocal":"2009-11-15T09:58:12Z","activityId":48973,"timeZoneOffset":-8.0,"athlete":{"username":"hobe","name":"Daniel Hobe","id":1113},"elapsedTime":352,"id":381555},{"startDate":"2010-07-08T13:54:41Z","startDateLocal":"2010-07-08T06:54:41Z","activityId":133179,"timeZoneOffset":-8.0,"athlete":{"username":"kmok","name":"Kent Mok","id":4607},"elapsedTime":352,"id":1547618},{"startDate":"2010-07-11T15:24:40Z","startDateLocal":"2010-07-11T08:24:40Z","activityId":134535,"timeZoneOffset":-8.0,"athlete":{"username":"nskinner","name":"nate skinner","id":1217},"elapsedTime":356,"id":1582023},{"startDate":"2009-09-16T14:45:42Z","startDateLocal":"2009-09-16T06:45:42Z","activityId":36407,"timeZoneOffset":-8.0,"athlete":{"username":"roderic","name":"R. Campbell","id":983},"elapsedTime":357,"id":170273},{"startDate":"2010-07-01T13:53:02Z","startDateLocal":"2010-07-01T06:53:02Z","activityId":128915,"timeZoneOffset":-8.0,"athlete":{"username":"mrampton","name":"Mark Rampton","id":1375},"elapsedTime":360,"id":1463925},{"startDate":"2009-09-27T20:19:43Z","startDateLocal":"2009-09-27T13:19:43Z","activityId":94786,"timeZoneOffset":-8.0,"athlete":{"username":"chilsenbeck","name":"c. hilsenbeck","id":4569},"elapsedTime":362,"id":908201},{"startDate":"2007-10-06T23:19:48Z","startDateLocal":"2007-10-06T15:19:48Z","activityId":43221,"timeZoneOffset":-8.0,"athlete":{"username":"shannon","name":"Shannon Coen","id":1137},"elapsedTime":366,"id":326985},{"startDate":"2010-08-27T02:30:56Z","startDateLocal":"2010-08-26T19:30:56Z","activityId":181412,"timeZoneOffset":-8.0,"athlete":{"username":"cgoldstein","name":"Cliff Goldstein","id":7649},"elapsedTime":367,"id":2473678},{"startDate":"2010-05-19T00:54:09Z","startDateLocal":"2010-05-18T17:54:09Z","activityId":104215,"timeZoneOffset":-8.0,"athlete":{"username":"kjeffers","name":"Kyle Jeffers","id":4540},"elapsedTime":370,"id":1047624}],"segment":{"name":"Hawk Hill Saddle","id":99243}}'
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/segments/99243/efforts', {:query => {'clubId' => 15, 'best' => true}}).returns(api_result)

    result = @s.segment_efforts(99243, {:club_id => 15, :best => true})
    
    assert result.is_a?(Array)
    
    result.each do |effort|
      assert effort.is_a?(Strava::Effort)
    end
    
    athletes = result.collect {|e| e.athlete.username}.sort
    i = 0
    while i < athletes.length do
      assert athletes[i] != athletes[i+1], "Problem -- two athletes in the list with the same username"
      i += 1
    end
  end
  
  def test_effort_show
    #curl http://www.strava.com/api/v1/efforts/688432
    api_result = JSON.parse '{"effort":{"ride":{"name":"02/28/10 San Francisco, CA","id":77563},"averageSpeed":14317.7658862876,"startDate":"2010-02-28T18:10:07Z","averageWatts":287.765,"startDateLocal":"2010-02-28T10:10:07Z","maximumSpeed":18894.384,"timeZoneOffset":-8.0,"athlete":{"username":"julianbill","name":"Julian Bill","id":1139},"elevationGain":151.408,"distance":2344.82,"elapsedTime":598,"segment":{"name":"Panoramic to Pan Toll","id":156},"id":688432,"movingTime":598}}'
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/efforts/688432', { :query => {} }).returns(api_result)

    result = @s.effort_show(688432)
    
    assert result.is_a?(Strava::Effort)
    assert result.elapsed_time == 598
    assert result.athlete.is_a?(Strava::Member)
    assert result.athlete.name == "Julian Bill"
    assert result.average_speed == 14317.7658862876
    assert result.id == 688432
    #assert result.start_date == Time.parse('2010-02-28T18:10:07Z')
    assert result.time_zone_offset == -8.0
    assert result.maximum_speed == 18894.384
    assert result.average_watts == 287.765
    assert result.elevation_gain == 151.408
    assert result.ride.is_a?(Strava::Ride)
    assert result.ride.name == "02/28/10 San Francisco, CA"
    assert result.moving_time == 598
    assert result.distance == 2344.82
    assert result.segment.is_a?(Strava::Segment)
    assert result.segment.name == "Panoramic to Pan Toll"
  end
end
