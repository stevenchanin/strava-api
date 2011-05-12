require 'helper'
require 'mocha'
require 'json'

class TestUserAuthentication < Test::Unit::TestCase
  def setup
    @s = StravaApi::Base.new
  end
  
  def test_login_failure  
    api_result = JSON.parse login_failure_json
    api_result.stubs(:parsed_response).returns("")
    StravaApi::Base.stubs(:post).with('/authentication/login', {:body => {:email => "fail@gmail.com", :password => "secret"}}).returns(api_result)

    expect_error(StravaApi::AuthenticationError) { @s.login("fail@gmail.com", "secret") }
  end


  def test_login_success
    api_result = JSON.parse login_success_json
    api_result.stubs(:parsed_response).returns("")
    StravaApi::Base.stubs(:post).with('/authentication/login', { :body => {:email => "success@gmail.com", :password => "secret"} }).returns(api_result)
  
    user = @s.login("success@gmail.com", "secret")
    
    assert_instance_of StravaApi::User, user
    assert_equal "d41d8cd98f00b204e980", user.token
    assert_equal 1234, user.athlete_id
    assert_instance_of StravaApi::Settings, user.default_settings
  end

  
end