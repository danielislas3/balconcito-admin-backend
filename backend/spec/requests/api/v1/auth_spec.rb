require 'rails_helper'

RSpec.describe "Api::V1::Auth", type: :request do
  let(:user) { create(:user, email: 'test@example.com', password: 'password123') }

  describe "POST /api/v1/auth/login" do
    context "with valid credentials" do
      it "returns a JWT token and user data" do
        post '/api/v1/auth/login', params: {
          email: user.email,
          password: 'password123'
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        
        expect(json['token']).to be_present
        expect(json['token']).to be_a(String)
        
        expect(json['user']).to be_present
        expect(json['user']['id']).to eq(user.id)
        expect(json['user']['email']).to eq(user.email)
        expect(json['user']['name']).to eq(user.name)
        expect(json['user']['role']).to eq(user.role)
      end
    end

    context "with invalid password" do
      it "returns unauthorized error" do
        post '/api/v1/auth/login', params: {
          email: user.email,
          password: 'wrong_password'
        }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to be_present
        expect(json['error']).to eq('Invalid email or password')
      end
    end

    context "with non-existent user" do
      it "returns unauthorized error" do
        post '/api/v1/auth/login', params: {
          email: 'nonexistent@example.com',
          password: 'password123'
        }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to be_present
        expect(json['error']).to eq('Invalid email or password')
      end
    end

    context "with missing parameters" do
      it "handles missing email" do
        post '/api/v1/auth/login', params: {
          password: 'password123'
        }

        expect(response).to have_http_status(:unauthorized)
      end

      it "handles missing password" do
        post '/api/v1/auth/login', params: {
          email: user.email
        }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
