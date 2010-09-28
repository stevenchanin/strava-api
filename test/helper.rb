require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'strava'

class Test::Unit::TestCase
  def expect_error(error, &block)
    begin
      block.call
    rescue error
      assert true
    else
      assert false
    end
  end
end
