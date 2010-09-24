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
  end
  
  def test_club_members
    result = @s.club_members(23)
    
    assert result.is_a?(Array)
    result.each do |member|
      assert member.is_a?(Strava::Member)
    end
  end

end
