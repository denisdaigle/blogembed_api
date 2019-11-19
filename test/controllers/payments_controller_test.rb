require 'test_helper'

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  test "should get v1_process_upgrade" do
    get payments_v1_process_upgrade_url
    assert_response :success
  end

end
