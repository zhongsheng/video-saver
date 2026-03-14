class CleanupVideoAssetJob < ApplicationJob
  queue_as :default

  def perform(video_asset_id)
    video_asset = VideoAsset.find_by(id: video_asset_id)
    return unless video_asset

    video_asset.update!(status: :expired) unless video_asset.expired?
  end
end
