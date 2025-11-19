class ApplicationController < ActionController::API
  include ActionController::MimeResponds

  before_action :authenticate_user!

  respond_to :json

  private

  # Devise authentication method
  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last

    if token.blank?
      render json: { error: 'You need to sign in or sign up before continuing.' }, status: :unauthorized
      return
    end

    begin
      jwt_payload = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS256' }).first
      @current_user = User.find(jwt_payload['user_id'])
    rescue JWT::ExpiredSignature
      render json: { error: 'Token has expired' }, status: :unauthorized
    rescue JWT::DecodeError
      render json: { error: 'Invalid token' }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def render_error(message, status = :unprocessable_entity)
    render json: { error: message }, status: status
  end

  def render_success(data, message = nil, status = :ok)
    response = data
    response = response.merge(message: message) if message
    render json: response, status: status
  end
end
