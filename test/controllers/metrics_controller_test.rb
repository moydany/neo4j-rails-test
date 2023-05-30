require 'test_helper'

class MetricsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @key = "test-key-#{Time.now.to_i}"
    @metric = Metric.create(name: "Test Metric", key: @key, value: 10, timestamp: Time.now.to_i)
  end

  def teardown
    @metric.destroy
  end

  test "should get index" do
    get '/metrics/all'
    assert_response :success
  end

  test "should create metric" do
    new_key = "test-key-new-#{Time.now.to_i}"
    assert_difference('Metric.count') do
      post "/metric/#{new_key}", params: { metric: { name: "TestMetric", value: 20 } }
    end
    assert_response :created
  end

  test "should not create metric with existing key" do
    assert_no_difference('Metric.count') do
      post "/metric/#{@key}", params: { metric: { name: "TestMetric", value: 20 } }
    end
    assert_response :conflict
  end

  test "should show metric by key" do
    get "/metric/key/#{@key}"
    assert_response :success
  end

  test "should show metric by name" do
    get "/metric/name/TestMetric"
    assert_response :success
  end

  test "should destroy metric" do
    assert_difference('Metric.count', -1) do
      delete "/metric/#{@key}"
    end
    assert_response :success
  end

  test "should not destroy non-existing metric" do
    assert_no_difference('Metric.count') do
      delete "/metric/non-existing-key"
    end
    assert_response :not_found
  end
end
