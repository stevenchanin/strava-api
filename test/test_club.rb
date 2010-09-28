require 'helper'
require 'mocha'
require 'json'

class TestClub < Test::Unit::TestCase
  def setup
    @s = Strava::Base.new

    api_result = JSON.parse clubs_index_json
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/clubs', {:query => {:name => 'X'}}).returns(api_result)

    @club = @s.clubs("X").first
  end
  
  def test_show
    api_result = JSON.parse club_show_json
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/clubs/23', { :query => {} }).returns(api_result)

    assert @club.description.nil?
    assert @club.location.nil?

    result = @club.show
    
    assert result.is_a?(Strava::Club)
    
    assert @club.description == "SLO Nexus brings together people who love to ride bikes, race bikes, and promote bike riding in our community. Our fresh outlook on the local bike scene incorporates support, fun, education, and fitness and is designed to bring together the growing number"
    assert @club.location == "San Luis Obispo, CA"
  end
  
  def test_members
    api_result = JSON.parse club_members_json
    api_result.stubs(:parsed_response).returns("")
    Strava::Base.stubs(:get).with('/clubs/23/members', { :query => {} }).returns(api_result)

    members = @club.members
    
    assert members.is_a?(Array)
    assert members.size == 6
    members.each do |member|
      assert member.is_a?(Strava::Member)
    end
  end
end