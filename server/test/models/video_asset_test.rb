require "test_helper"

class VideoAssetTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(wechat_openid: "openid-123")
  end

  test "status transitions follow state graph" do
    asset = VideoAsset.create!(
      user: @user,
      source_message_id: "msg-1",
      source_url: "https://example.com/video.mp4"
    )

    assert_equal "received", asset.status

    asset.mark_downloading!
    assert_equal "downloading", asset.status

    asset.mark_ready!(
      storage_path: "videos/1.mp4",
      file_size: 10_000,
      duration_ms: 2_000,
      expires_at: 1.day.from_now
    )
    assert_equal "ready", asset.status

    asset.mark_downloaded!
    assert_equal "downloaded", asset.status

    asset.mark_deleted!
    assert_equal "deleted", asset.status
  end

  test "invalid transition raises" do
    asset = VideoAsset.create!(
      user: @user,
      source_message_id: "msg-2",
      source_url: "https://example.com/video.mp4"
    )

    error = assert_raises(ActiveRecord::RecordInvalid) do
      asset.mark_ready!(
        storage_path: "videos/2.mp4",
        file_size: 10_000,
        duration_ms: 2_000,
        expires_at: 1.day.from_now
      )
    end

    assert_match(/cannot transition from received to ready/, error.message)
  end

  test "failed status requires failure reason" do
    asset = VideoAsset.new(
      user: @user,
      source_message_id: "msg-3",
      source_url: "https://example.com/video.mp4",
      status: "failed"
    )

    assert_not asset.valid?
    assert_includes asset.errors[:failure_reason], "can't be blank"
  end
end
