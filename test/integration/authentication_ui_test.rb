require "test_helper"

class AuthenticationUiTest < ActionDispatch::IntegrationTest
  test "login fields use readable text on their dark background" do
    get new_session_path

    assert_response :success
    assert_select "input[name='email_address'][class~='text-white']"
    assert_select "input[name='password'][class~='text-white']"
  end
end
