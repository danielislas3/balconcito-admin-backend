module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_user!, only: [:login]

      # POST /api/v1/auth/login
      def login
        user = User.find_by(email: params[:email])

        if user&.valid_password?(params[:password])
          token = generate_jwt(user)
          render json: {
            token: token,
            user: {
              id: user.id,
              email: user.email,
              name: user.name,
              role: user.role
            }
          }, status: :ok
        else
          render_error('Invalid email or password', :unauthorized)
        end
      end

      # DELETE /api/v1/auth/logout
      def logout
        # JWT tokens are stateless, so we just return success
        # In a future version, we could blacklist the token
        render json: { message: 'Logged out successfully' }, status: :ok
      end

      # GET /api/v1/auth/me
      def me
        render json: {
          user: {
            id: current_user.id,
            email: current_user.email,
            name: current_user.name,
            role: current_user.role
          }
        }, status: :ok
      end

      private

      def generate_jwt(user)
        payload = {
          user_id: user.id,
          exp: 24.hours.from_now.to_i
        }
        JWT.encode(payload, Rails.application.credentials.secret_key_base)
      end
    end
  end
end
