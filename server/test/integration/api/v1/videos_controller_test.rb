require "test_helper"

class Api::V1::VideosControllerTest < ActionDispatch::IntegrationTest
  test "ingest creates video asset" do
    post "/api/v1/videos/ingest",
         params: {
           wechat_openid: "openid_1",
           source_message_id: "msg_1",
           source_url: "https://example.com/video.mp4"
         },
         as: :json

    assert_response :created
    json = response.parsed_body
    assert_equal "video_ingested", json["code"]
    assert_equal "received", json.dig("data", "status")
  end

  test "show returns task status" do
    video = VideoAsset.create!(
      wechat_openid: "openid_2",
      source_message_id: "msg_2",
      source_url: "https://example.com/video.mp4",
      status: :processing
    )

    get "/api/v1/videos/#{video.id}", as: :json

    assert_response :success
    json = response.parsed_body
    assert_equal "ok", json["code"]
    assert_equal "processing", json.dig("data", "status")
  end

  test "download token and complete flow" do
    video = VideoAsset.create!(
      wechat_openid: "openid_3",
      source_message_id: "msg_3",
      source_url: "https://example.com/video.mp4",
      status: :ready
    )

    post "/api/v1/videos/#{video.id}/download_token", as: :json
    assert_response :success
    token = response.parsed_body.dig("data", "token")
    assert_not_nil token

    get "/api/v1/videos/#{video.id}/download", params: { token: token }
    assert_response :redirect
    assert_equal "https://example.com/video.mp4", response.location

    post "/api/v1/videos/#{video.id}/complete", as: :json
    assert_response :success
    assert_equal "video_completed", response.parsed_body["code"]
    assert_equal "downloaded", VideoAsset.find(video.id).status
  end
end
