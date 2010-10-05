require 'helper'
require 'mocha'
require 'json'

class TestSegment < Test::Unit::TestCase
  def setup
    @s = StravaApi::Base.new

    api_result = JSON.parse segments_index_json
    api_result.stubs(:parsed_response).returns("")
    StravaApi::Base.stubs(:get).with('/segments', {:query => {:name => 'Hawk Hill'}}).returns(api_result)

    @segment = @s.segments("Hawk Hill").first
  end
  
  def test_show
    api_result = JSON.parse segment_show_json
    api_result.stubs(:parsed_response).returns("")
    StravaApi::Base.stubs(:get).with('/segments/99243', { :query => {} }).returns(api_result)

    assert @segment.id == 99243
    assert @segment.name == "Hawk Hill Saddle"
    assert @segment.elevation_gain.nil?
    assert @segment.elevation_high.nil?

    result = @segment.show
    assert result.is_a?(StravaApi::Segment)
    
    assert @segment.id == 99243
    assert @segment.name == "Hawk Hill Saddle"
    assert @segment.elevation_gain == 76.553
    assert @segment.elevation_high == 172.694
  end

  def test_efforts
    api_result = JSON.parse segment_efforts_index_json
    api_result.stubs(:parsed_response).returns("")
    StravaApi::Base.stubs(:get).with('/segments/99243/efforts', { :query => {} }).returns(api_result)
    
    efforts = @segment.efforts
    
    assert efforts.is_a?(Array)
    assert efforts.size == 3
    efforts.each do |effort|
      assert effort.is_a?(StravaApi::Effort)
    end
  end
  
  def test_efforts_with_athlete_id
    api_result = JSON.parse segment_efforts_index_by_athlete_id_json
    api_result.stubs(:parsed_response).returns("")
    StravaApi::Base.stubs(:get).with('/segments/99243/efforts', { :query => {'athleteId' => 1377} }).returns(api_result)
    
    efforts = @segment.efforts(:athlete_id => 1377)
    
    assert efforts.is_a?(Array)

    assert efforts.size == 17
    efforts.each do |effort|
      assert effort.is_a?(StravaApi::Effort)
    end
  end
end