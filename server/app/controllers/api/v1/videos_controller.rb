module Api
  module V1
    class VideosController < BaseController
      before_action :ensure_json_request!, only: %i[ingest download_token complete]
      before_action :set_video_asset, except: :ingest

      def ingest
        attrs = ingest_params
        video_asset = VideoAsset.find_or_initialize_by(
          wechat_openid: attrs[:wechat_openid],
          source_message_id: attrs[:source_message_id]
        )

        video_asset.assign_attributes(
          source_url: attrs[:source_url],
          media_id: attrs[:media_id],
          status: :received
        )
        video_asset.save!

        render_success(
          code: "video_ingested",
          message: "Video asset received.",
          data: serialize_video(video_asset),
          status: :created
        )
      end

      def show
        render_success(data: serialize_video(@video_asset))
      end

      def download_token
        token = @video_asset.short_lived_download_token
        render_success(
          code: "download_token_issued",
          message: "Download token issued.",
          data: { token: token, expires_in: 600 }
        )
      end

      def download
        validate_download_token!
        @video_asset.update!(download_started_at: Time.current)

        if @video_asset.source_url.present?
          redirect_to @video_asset.source_url, allow_other_host: true
        else
          raise ApiError.new(code: "download_unavailable", message: "No source URL is available for this video.", status: :unprocessable_entity)
        end
      end

      def complete
        @video_asset.update!(status: :downloaded, downloaded_at: Time.current)
        CleanupVideoAssetJob.perform_later(@video_asset.id)

        render_success(code: "video_completed", message: "Video download completion recorded.", data: serialize_video(@video_asset))
      end

      private

      def set_video_asset
        @video_asset = VideoAsset.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        raise ApiError.new(code: "video_not_found", message: "Video asset not found.", status: :not_found)
      end

      def ingest_params
        allowed = params.permit(:wechat_openid, :source_message_id, :source_url, :media_id)
        params.require(:wechat_openid)
        params.require(:source_message_id)

        unless allowed[:source_url].present? || allowed[:media_id].present?
          raise ApiError.new(code: "invalid_params", message: "source_url or media_id is required.", status: :unprocessable_entity)
        end

        allowed
      end

      def validate_download_token!
        token = params[:token].to_s
        raise ApiError.new(code: "missing_token", message: "Download token is required.", status: :unauthorized) if token.blank?

        begin
          record = VideoAsset.find_signed!(token, purpose: "video_download")
          return if record.id == @video_asset.id
        rescue ActiveSupport::MessageVerifier::InvalidSignature
          # handled below
        end

        raise ApiError.new(code: "invalid_token", message: "Download token is invalid or expired.", status: :unauthorized)
      end

      def serialize_video(video)
        {
          id: video.id,
          wechat_openid: video.wechat_openid,
          source_message_id: video.source_message_id,
          status: video.task_status,
          source_url: video.source_url,
          media_id: video.media_id,
          download_started_at: video.download_started_at,
          downloaded_at: video.downloaded_at,
          expires_at: video.expires_at,
          created_at: video.created_at,
          updated_at: video.updated_at
        }
      end
    end
  end
end
