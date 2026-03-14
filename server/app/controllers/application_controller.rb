class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rescue_from ApiError, with: :render_api_error
  rescue_from ActionController::ParameterMissing, with: :render_parameter_missing
  rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid

  private

  def render_api_error(error)
    render json: {
      code: error.code,
      message: error.message,
      data: error.details || {}
    }, status: error.status
  end

  def render_parameter_missing(error)
    render json: {
      code: "invalid_params",
      message: error.message,
      data: {}
    }, status: :unprocessable_entity
  end

  def render_record_invalid(error)
    render json: {
      code: "validation_failed",
      message: error.record.errors.full_messages.join(", "),
      data: { errors: error.record.errors.to_hash }
    }, status: :unprocessable_entity
  end
end
