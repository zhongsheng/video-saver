class VideoAsset < ApplicationRecord
  enum :status, {
    received: 0,
    processing: 1,
    ready: 2,
    expired: 3,
    failed: 4,
    downloaded: 5
  }, default: :received

  validates :wechat_openid, :source_message_id, presence: true
  validates :source_url, presence: true, unless: -> { media_id.present? }
  validates :media_id, presence: true, unless: -> { source_url.present? }

  def task_status
    return "expired" if expires_at.present? && expires_at.past? && !downloaded?

    status
  end

  def short_lived_download_token(expires_in: 10.minutes)
    signed_id(purpose: "video_download", expires_in: expires_in)
  end
end
