require 'helper'
require 'mocha'
require 'json'

class TestClubs < Test::Unit::TestCase
  ###### Testing Strava::Base
  def setup
    @s = Strava::Base.new
  end

  def test_clubs_no_search_string
    expect_error(Strava::CommandError) { @s.clubs('') }
  end
  
  def test_clubs_all_spaces_search_string
    expect_error(Strava::CommandError) { @s.clubs('  ') }
  end

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
end