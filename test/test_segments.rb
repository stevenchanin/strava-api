require 'helper'
require 'mocha'
require 'json'

class TestSegments < Test::Unit::TestCase
  def setup
    @s = StravaApi::Base.new
  end
  def test_segments_index
    #curl http://www.strava.com/api/v1/segments?name=hawk%20hill
    api_result = JSON.parse segments_index_json
    api_result.stubs(:parsed_response).returns("")
    StravaApi::Base.stubs(:get).with('/segments', {:query => {:name => 'Hawk Hill'}}).returns(api_result)

    result = @s.segments('Hawk Hill')
    
    assert result.is_a?(Array)

    result.each do |segment|
      assert segment.is_a?(StravaApi::Segment)
    end
  end

  def test_segments_index_that_returns_nothing
    #curl http://www.strava.com/api/v1/segments?name=hawk%20hillxxxy
    api_result = JSON.parse '{"segments":[]}'
    api_result.stubs(:parsed_response).returns("")
    StravaApi::Base.stubs(:get).with('/segments', {:query => {:name => 'Hawk Hill98xcasdf'}}).returns(api_result)

    result = @s.segments('Hawk Hill98xcasdf')
    
    assert result.is_a?(Array)
    assert result.empty?
  end

  def test_segment_show
    #rl http://www.strava.com/api/v1/segments/99243
    api_result = JSON.parse segment_show_json
    api_result.stubs(:parsed_response).returns("")
    StravaApi::Base.stubs(:get).with('/segments/99243', { :query => {} }).returns(api_result)

    result = @s.segment_show(99243)
    
    assert result.is_a?(StravaApi::Segment)
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
    StravaApi::Base.stubs(:get).with('/segments/0/efforts', {:query => {}}).returns(api_result)

    expect_error(StravaApi::InvalidResponseError) { @s.segment_efforts(0) }
    
    assert @s.errors.include?("Invalid segments/0")
  end
  
  def test_segment_efforts_index
    #curl http://www.strava.com/api/v1/segments/99243/efforts
    #note: cut some out because the response was so long
    api_result = JSON.parse segment_efforts_index_json
    api_result.stubs(:parsed_response).returns("")
    StravaApi::Base.stubs(:get).with('/segments/99243/efforts', {:query => {}}).returns(api_result)

    result = @s.segment_efforts(99243)
    
    assert result.is_a?(Array)
    
    result.each do |effort|
      assert effort.is_a?(StravaApi::Effort)
    end
  end

  def test_segment_efforts_index_by_athlete_id
    #curl http://www.strava.com/api/v1/segments/99243/efforts?athleteId=1377
    api_result = JSON.parse segment_efforts_index_by_athlete_id_json
    api_result.stubs(:parsed_response).returns("")
    StravaApi::Base.stubs(:get).with('/segments/99243/efforts', {:query => {'athleteId' => 1377}}).returns(api_result)

    result = @s.segment_efforts(99243, {:athlete_id => 1377})
    
    assert result.is_a?(Array)
    
    result.each do |effort|
      assert effort.is_a?(StravaApi::Effort)
      assert effort.athlete.id == 1377, "#{effort.athlete.id} != 1377"
    end
  end

  def test_segment_efforts_index_by_athlete_id_and_start_date
    #curl "http://www.strava.com/api/v1/segments/99243/efforts?athleteId=1377&startDate=2010-07-01"
    api_result = JSON.parse segment_efforts_index_by_athlete_id_and_start_date_json
    api_result.stubs(:parsed_response).returns("")
    StravaApi::Base.stubs(:get).with('/segments/99243/efforts', {:query => {'athleteId' => 1377, 'startDate' => Date.civil(2010,7,1)}}).returns(api_result)

    result = @s.segment_efforts(99243, {:athlete_id => 1377, :start_date => Date.civil(2010,7,1)})
    
    assert result.is_a?(Array)
    
    result.each do |effort|
      assert effort.is_a?(StravaApi::Effort)
      assert effort.athlete.id == 1377, "#{effort.athlete.id} != 1377"

      #works with the real api call, but the stub that is just JSON parsing isn't converting times to Time objects
      #assert effort.start_date >= Time.utc(2010,7,1), "#{effort.start_date} < 2010-7-1"
    end
  end

  def test_segment_efforts_index_by_club_id_and_best
    #using test data for club 15
    #curl http://www.strava.com/api/v1/segments/99243/efforts?clubId=15&best=true
    api_result = JSON.parse segment_efforts_index_by_club_id_and_best_json
    api_result.stubs(:parsed_response).returns("")
    StravaApi::Base.stubs(:get).with('/segments/99243/efforts', {:query => {'clubId' => 15, 'best' => true}}).returns(api_result)

    result = @s.segment_efforts(99243, {:club_id => 15, :best => true})
    
    assert result.is_a?(Array)
    
    result.each do |effort|
      assert effort.is_a?(StravaApi::Effort)
    end
    
    athletes = result.collect {|e| e.athlete.username}.sort
    i = 0
    while i < athletes.length do
      assert athletes[i] != athletes[i+1], "Problem -- two athletes in the list with the same username"
      i += 1
    end
  end
  
  def test_segment_efforts_index_using_offset
    #curl http://www.strava.com/api/v1/segments/99243/efforts
    api_result = JSON.parse segment_efforts_index_using_offset_json
    api_result.stubs(:parsed_response).returns("")
    StravaApi::Base.stubs(:get).with('/segments/99243/efforts', {:query => {}}).returns(api_result)

    api_result2 = JSON.parse segment_efforts_index_using_offset_50_json
    api_result2.stubs(:parsed_response).returns("")
    StravaApi::Base.stubs(:get).with('/segments/99243/efforts', {:query => {'offset' => 50}}).returns(api_result2)

    set_1 = @s.segment_efforts(99243)
    set_2 = @s.segment_efforts(99243, :offset => 50)

    assert set_1.is_a?(Array)
    assert set_2.is_a?(Array)
    
    set_1.each {|ride| assert ride.is_a?(StravaApi::Effort)}
    set_2.each {|ride| assert ride.is_a?(StravaApi::Effort)}
    
    #but there shouldn't be any overlap
    set_1_ids = set_1.collect(&:id)
    set_2_ids = set_2.collect(&:id)
    
    set_1_ids.each do |set_1_id|
      assert !set_2_ids.include?(set_1_id), "Error: #{set_1_id} is included in both sets"
    end
  end
end
