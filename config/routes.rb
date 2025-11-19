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
        get :summary, to: 'summary#index'
        get :profitability, to: 'profitability#index'
        get :break_even, to: 'break_even#index'
        get :cash_flow, to: 'cash_flow#index'
        get :expense_breakdown, to: 'expense_breakdown#index'
      end
    end
  end
end
