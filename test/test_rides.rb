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
  
  def test_rides_using_offset
    #curl "http://www.strava.com/api/v1/rides?athleteId=779&startDate=2010-07-1&endDate=2010_09_01"
    api_result = JSON.parse '{"rides":[{"name":"07/05/10 Chula Vista, CA","id":143214},{"name":"Los Gatos Apple Store","id":139046},{"name":"07/05/10 Kellyville Ridge, NSW, Australia","id":170913},{"name":"Day2 Right to Play, Bruge to Calais: Fast group riding surrounded by flat fields","id":132963},{"name":"07/05/10 Marysville, WA","id":139462},{"name":"07/05/10 Joondanna, WA, Australia","id":145125},{"name":"07/05/10 Kellyville Ridge, NSW, Australia","id":170916},{"name":"07/05/10 Salt Lake City, UT","id":133548},{"name":"07/05/10 San Jose, CA","id":139045},{"name":"07/05/10 Fremont, CA","id":132007},{"name":"Spruce to Euclid","id":136015},{"name":"Twin Peaks, both ways","id":131961},{"name":"07/05/10 BE","id":131948},{"name":"07/05/10 Phoenix, AZ","id":136736},{"name":"07/05/10 Portland, OR - Monday PIR July #1","id":155635},{"name":"16 mile Hendricks-Ridgeline loop","id":132128},{"name":"07/05/10 Vancouver, BC, Canada","id":133953},{"name":"07/05/10 Portland, OR","id":133045},{"name":"Strava is Farmville for Cyclists","id":132186},{"name":"07/05/10 Rosslea, Fermanagh, United Kingdom","id":131609},{"name":"Home to PVHS to Home","id":131958},{"name":"07/05/10 Ravensdale, WA","id":143560},{"name":"UP to Dupont","id":131978},{"name":"07/05/10 Norwich, VT","id":132082},{"name":"07/05/10 Austin, TX","id":174324},{"name":"from SVRMC","id":132010},{"name":"07/05/10 Norwich, VT","id":131938},{"name":"07/05/10 Infa to Lucan (partial)","id":131533},{"name":"07/05/10 North Sydney, NSW, Australia","id":136579},{"name":"07/05/10 Danville, CA","id":174936},{"name":"07/05/10 West Leederville, WA, Australia","id":136711},{"name":"07/05/10 Foothill Ranch, CA","id":132364},{"name":"07/05/10 San Jose, CA","id":131917},{"name":"07/05/10 Alpena, MI","id":132243},{"name":"07/05/10 Alpena, MI","id":164681},{"name":"07/05/10 San Diego, CA","id":131991},{"name":"07/05/10 Paradise Loop (short) & Gilmartin Drive","id":131906},{"name":"07/05/10 San Francisco, CA","id":131959},{"name":"07/05/10 Woodside, CA kings-skyline-page mill","id":132008},{"name":"07/05/10 San Diego, CA","id":132055},{"name":"07/05/10 Subiaco, WA, Australia","id":145126},{"name":"Recovery Ride","id":131951},{"name":"07/05/10 Borehamwood, Greater London","id":142057},{"name":"07/05/10 Crowmarsh, Oxfordshire, United Kingdom","id":131604},{"name":"07/05/10 Daglish, WA, Australia","id":162047},{"name":"2x voie maritime ","id":131904},{"name":"Coyote Hills Quickie (500)","id":131935},{"name":"Oakland Hills","id":135793},{"name":"Powercranks - Hill Road","id":131900},{"name":"07/05/10 San Jose, CA","id":136352}]}'
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/rides', { :query => {'startDate' => Date.civil(2010,7,1),
      'endDate' => Date.civil(2010,7,5)} }).returns(api_result)

    api_result2 = JSON.parse '{"rides":[{"name":"07/05/10 Moraga, CA","id":178455},{"name":"07/05/10 Oakland, CA","id":138353},{"name":"07/05/10 Bay Farm Loop","id":146047},{"name":"07/05/10 Bath, Bath and North East Somerset, United Kingdom","id":132105},{"name":"07/05/10 Apeldoorn, Gelderland, The Netherlands","id":165396},{"name":"Paradise out n back","id":134426},{"name":"07/05/10 Apeldoorn, Gelderland, The Netherlands","id":165391},{"name":"Westridge/Portola/OLH/Woodside","id":131924},{"name":"07/05/10 Arlington, TX","id":133900},{"name":"Neighborhood Ride","id":133147},{"name":"731 to Pekin 73 Loop","id":131884},{"name":"07/05/10 Cheyenne, WY","id":132067},{"name":"07/05/10 Norwich, VT","id":131802},{"name":"MCX Washout","id":132220},{"name":"07/05/10 San Francisco, CA","id":132392},{"name":"07/05/10 Redwood City, CA","id":143306},{"name":"07/05/10 San Francisco, CA","id":132230},{"name":"07/05/10 Reverse Paradise, CA","id":131964},{"name":"07/05/10 Milledgeville, GA","id":131696},{"name":"07/05/10 Turlock, CA","id":132184},{"name":"Paradise","id":131949},{"name":"07/05/10 Polo Fields","id":131852},{"name":"07/05/10 Oakland, CA","id":152256},{"name":"Top Hat and Union Hill Exploration","id":150023},{"name":"07/05/10 Burlingame, CA","id":131888},{"name":"MCX Headlands- Flying Danno","id":132169},{"name":"07/05/10 Shady Spring, WV","id":132995},{"name":"07/05/10 Lake Oswego, OR","id":155989},{"name":"07/05/2010 Morgan Hill, CA","id":190222},{"name":"Trail ride to the emergency room","id":132131},{"name":"07/05/10 Quick loop (Hot day)","id":131658},{"name":"Ravensdale - Black Diamond","id":131992},{"name":"07/05/10 Fitchburg Criterium","id":135511},{"name":"07/05/10 San Francisco, CA","id":171941},{"name":"07/05/10 Truckee, CA","id":173709},{"name":"Foothill, Portola Loop","id":132345},{"name":"07/05/10 Fitchburg, MA crit (21)","id":131965},{"name":"07/05/10 Box Hill South, VIC, Australia","id":131433},{"name":"Fitchburg Crit","id":133775},{"name":"07/05/10 West Melbourne, FL","id":133043},{"name":"07/05/10 Norwich, VT","id":132670},{"name":"07/05/10 Redmond, WA","id":160497},{"name":"out and back to bike hub","id":132370},{"name":"Harbins","id":136301},{"name":"07/05/10 Fair Oaks, CA","id":131843},{"name":"SF-Fairfax-ChinaCamp","id":132006},{"name":"07/05/10 San Francisco, CA","id":178832},{"name":"07/05/10 Agoura Hills, CA","id":131988},{"name":"Nisene Ride","id":156100},{"name":"07/05/10 Richmond, CA","id":142917}]}'
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
