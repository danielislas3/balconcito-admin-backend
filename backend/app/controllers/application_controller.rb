class ApplicationController < ActionController::API
  before_action :authenticate_user!

  respond_to :json

  private

  def render_error(message, status = :unprocessable_entity)
    render json: { error: message }, status: status
  end

  def render_success(data, message = nil, status = :ok)
    response = data
    response = response.merge(message: message) if message
    render json: response, status: status
  end
end
