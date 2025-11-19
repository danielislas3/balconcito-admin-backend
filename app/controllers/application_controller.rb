class ApplicationController < ActionController::API
  before_action :authenticate_user!

  respond_to :json

  private

  def authenticate_user!
    header = request.headers['Authorization']

    unless header
      render json: { error: 'Missing authorization header' }, status: :unauthorized and return
    end

    token = header.split(' ').last

    begin
      decoded = decode_jwt(token)
      @current_user = User.find(decoded[:user_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :unauthorized and return
    rescue JWT::DecodeError, JWT::ExpiredSignature
      render json: { error: 'Invalid or expired token' }, status: :unauthorized and return
    end
  end

  def current_user
    @current_user
  end

  def decode_jwt(token)
    decoded = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS256' })
    HashWithIndifferentAccess.new(decoded[0])
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
