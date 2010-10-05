require 'helper'
require 'mocha'
require 'json'

class TestBase < Test::Unit::TestCase
  ###### Testing StravaApi::Base
  def setup
    @s = StravaApi::Base.new
  end

  def test_create
    assert @s.is_a?(StravaApi::Base)
  end
  
  def test_bad_command
    StravaApi::Base.stubs(:get).with('/clubsx', {:query => {}}).raises(StravaApi::NetworkError)

    expect_error(StravaApi::NetworkError) { @s.call('clubsx', 'club', {}) }
    
    assert @s.errors.include?("NetworkError from httparty")
  end
  
  def test_bad_command
    @response = mock('HTTParty::Response', :parsed_response => '<html><body><h1>500 Internal Server Error</h1></body></html>')
    StravaApi::Base.stubs(:get).with('/clubs', {:query => {}}).returns(@response)

    expect_error(StravaApi::CommandError) { @s.call('clubs', 'club', {}) }
    
    assert @s.errors.include?("Strava returned a 500 error")
  end

  #TODO: figure out how to stub out Httparty.get so I can test other errors
  
  def test_call_returns_response
    # result = @s.call('clubs', 'clubs', {:name => 'X'})

    #TODO: figure out why this fails, as far as I can tell result is an HTTPary::Response...
    #assert result.is_a?(HTTParty::Response)
  end
end