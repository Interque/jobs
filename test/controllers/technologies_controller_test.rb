require 'test_helper'

class TechnologiesControllerTest < ActionController::TestCase
  setup do
    @technology = technologies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:technologies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create technology" do
    assert_difference('Technology.count') do
      post :create, technology: { city: @technology.city, posted: @technology.posted, state: @technology.state, tech: @technology.tech }
    end

    assert_redirected_to technology_path(assigns(:technology))
  end

  test "should show technology" do
    get :show, id: @technology
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @technology
    assert_response :success
  end

  test "should update technology" do
    patch :update, id: @technology, technology: { city: @technology.city, posted: @technology.posted, state: @technology.state, tech: @technology.tech }
    assert_redirected_to technology_path(assigns(:technology))
  end

  test "should destroy technology" do
    assert_difference('Technology.count', -1) do
      delete :destroy, id: @technology
    end

    assert_redirected_to technologies_path
  end
end
