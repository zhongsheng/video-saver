class DownloadToken < ApplicationRecord
  belongs_to :video_asset

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true
end
