require "test_helper"

class Seller::ListingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get seller_listings_index_url
    assert_response :success
  end

  test "should get new" do
    get seller_listings_new_url
    assert_response :success
  end

  test "should get create" do
    get seller_listings_create_url
    assert_response :success
  end

  test "should get edit" do
    get seller_listings_edit_url
    assert_response :success
  end

  test "should get update" do
    get seller_listings_update_url
    assert_response :success
  end

  test "should get show" do
    get seller_listings_show_url
    assert_response :success
  end
end
