require "test_helper"

class ClientAssignmentsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get client_assignments_create_url
    assert_response :success
  end

  test "should get destroy" do
    get client_assignments_destroy_url
    assert_response :success
  end
end
