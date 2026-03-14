module Api
  module V1
    class BaseController < ApplicationController
      skip_forgery_protection

      private

      def ensure_json_request!
        return if request.format.json? || request.content_mime_type == Mime[:json]

        raise ApiError.new(code: "unsupported_media_type", message: "Only JSON requests are supported.", status: :unsupported_media_type)
      end

      def render_success(data: {}, code: "ok", message: "OK", status: :ok)
        render json: { code: code, message: message, data: data }, status: status
      end
    end
  end
end
