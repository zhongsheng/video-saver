class ApiError < StandardError
  attr_reader :code, :status, :details

  def initialize(code:, message:, status: :bad_request, details: nil)
    super(message)
    @code = code
    @status = status
    @details = details
  end
end
