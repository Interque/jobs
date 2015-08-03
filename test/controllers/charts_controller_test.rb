require 'test_helper'

class ChartsControllerTest < ActionController::TestCase
  test "should get tech_name" do
    get :tech_name
    assert_response :success
  end

end
