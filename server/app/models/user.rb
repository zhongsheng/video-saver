class User < ApplicationRecord
  has_many :video_assets, dependent: :destroy

  validates :wechat_openid, presence: true, uniqueness: true
end
