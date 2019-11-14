require 'test_helper'

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  test "should get process_upgrade" do
    get payments_process_upgrade_url
    assert_response :success
  end

end
