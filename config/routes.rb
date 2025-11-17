Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # API v1
  namespace :api do
    namespace :v1 do
      # Authentication
      post 'auth/login', to: 'auth#login'
      delete 'auth/logout', to: 'auth#logout'
      get 'auth/me', to: 'auth#me'

      # Resources
      resources :accounts, only: [:index, :show, :update]

      resources :turn_closures

      resources :expenses do
        collection do
          get :pending_reimbursement
        end
      end

      resources :payment_methods

      resources :reimbursements, only: [:index, :create, :show]

      # Dashboard
      namespace :dashboard do
        get :summary
        get :profitability
        get :break_even
        get :cash_flow
        get :expense_breakdown
      end
    end
  end
end
