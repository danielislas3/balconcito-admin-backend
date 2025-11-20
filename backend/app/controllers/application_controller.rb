class ApplicationController < ActionController::API
  include ActionController::MimeResponds

  before_action :authenticate_user!

  respond_to :json

  private

  def authenticate_user!
    Rails.logger.debug "🔐 [Auth] Starting authentication"
    Rails.logger.debug "🔐 [Auth] Request path: #{request.path}"

    header = request.headers['Authorization']
    Rails.logger.debug "🔐 [Auth] Authorization header: #{header ? "#{header[0..50]}..." : 'MISSING'}"

    unless header
      Rails.logger.debug "🔐 [Auth] ❌ No authorization header found"
      render json: { error: 'Missing authorization header' }, status: :unauthorized and return
    end

    token = header.split(' ').last
    Rails.logger.debug "🔐 [Auth] Extracted token: #{token[0..30]}..."

    begin
      decoded = decode_jwt(token)
      Rails.logger.debug "🔐 [Auth] Token decoded successfully: user_id=#{decoded[:user_id]}"

      @current_user = User.find(decoded[:user_id])
      Rails.logger.debug "🔐 [Auth] ✅ User found: #{@current_user.email}"
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.debug "🔐 [Auth] ❌ User not found: #{e.message}"
      render json: { error: 'User not found' }, status: :unauthorized and return
    rescue JWT::DecodeError => e
      Rails.logger.debug "🔐 [Auth] ❌ JWT DecodeError: #{e.message}"
      render json: { error: 'Invalid or expired token' }, status: :unauthorized and return
    rescue JWT::ExpiredSignature => e
      Rails.logger.debug "🔐 [Auth] ❌ JWT ExpiredSignature: #{e.message}"
      render json: { error: 'Invalid or expired token' }, status: :unauthorized and return
    rescue => e
      Rails.logger.debug "🔐 [Auth] ❌ Unexpected error: #{e.class} - #{e.message}"
      render json: { error: 'Authentication failed' }, status: :unauthorized and return
    end
  end

  def current_user
    @current_user
  end

  def decode_jwt(token)
    secret = ENV.fetch('JWT_SECRET_KEY') { Rails.application.secret_key_base }
    decoded = JWT.decode(token, secret, true, { algorithm: 'HS256' })
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
