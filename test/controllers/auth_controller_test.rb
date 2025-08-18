require "test_helper"

class AuthControllerTest < ActionDispatch::IntegrationTest
  test "should get validate" do
    get auth_validate_url
    assert_response :success
  end
end
