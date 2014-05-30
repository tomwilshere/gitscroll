require 'test_helper'

class FalsePositivesControllerTest < ActionController::TestCase
  setup do
    @false_positive = false_positives(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:false_positives)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create false_positive" do
    assert_difference('FalsePositive.count') do
      post :create, false_positive: { comment: @false_positive.comment, path: @false_positive.path, project_id: @false_positive.project_id, type: @false_positive.type }
    end

    assert_redirected_to false_positive_path(assigns(:false_positive))
  end

  test "should show false_positive" do
    get :show, id: @false_positive
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @false_positive
    assert_response :success
  end

  test "should update false_positive" do
    patch :update, id: @false_positive, false_positive: { comment: @false_positive.comment, path: @false_positive.path, project_id: @false_positive.project_id, type: @false_positive.type }
    assert_redirected_to false_positive_path(assigns(:false_positive))
  end

  test "should destroy false_positive" do
    assert_difference('FalsePositive.count', -1) do
      delete :destroy, id: @false_positive
    end

    assert_redirected_to false_positives_path
  end
end
