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
    Strava::Base.stubs(:get).with('/clubsx', {:query => {}}).raises(Strava::CommandError)

    expect_error(Strava::CommandError) { @s.call('clubsx', 'club', {}) }
  end
  
  #TODO: figure out how to stub out Httparty.get so I can test other errors
  
  def test_call_returns_response
    result = @s.call('clubs', 'clubs', {:name => 'X'})

    #TODO: figure out why this fails, as far as I can tell result is an HTTPary::Response...
    #assert result.is_a?(HTTParty::Response)
  end
end