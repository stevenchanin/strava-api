require 'helper'
require 'mocha'
require 'json'

class TestBase < Test::Unit::TestCase
  ###### Testing Strava::Base
  def setup
    @s = Strava::Base.new
  end

  def test_create
    assert @s.is_a?(Strava::Base)
  end
  
  def test_bad_command
    Strava::Base.stubs(:get).with('/clubsx', {:query => {}}).raises(Strava::NetworkError)

    expect_error(Strava::NetworkError) { @s.call('clubsx', 'club', {}) }
    
    assert @s.errors.include?("NetworkError from httparty")
  end
  
  def test_bad_command
    @response = mock('HTTParty::Response', :parsed_response => '<html><body><h1>500 Internal Server Error</h1></body></html>')
    Strava::Base.stubs(:get).with('/clubs', {:query => {}}).returns(@response)

    expect_error(Strava::CommandError) { @s.call('clubs', 'club', {}) }
    
    assert @s.errors.include?("Strava returned a 500 error")
  end

  #TODO: figure out how to stub out Httparty.get so I can test other errors
  
  def test_call_returns_response
    # result = @s.call('clubs', 'clubs', {:name => 'X'})

    #TODO: figure out why this fails, as far as I can tell result is an HTTPary::Response...
    #assert result.is_a?(HTTParty::Response)
  end
end