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

      resources :turn_closures do
        member do
          post :validate_with_loyverse
        end
        collection do
          post :preview_validation
        end
      end

      resources :expenses do
        collection do
          get :pending_reimbursement
        end
      end

      resources :reimbursements, only: [:index, :create, :show]

      # Dashboard
      namespace :dashboard do
        get :summary
        get :profitability
        get :break_even
        get :cash_flow
        get :expense_breakdown
        get :debt, to: 'debt#index'
      end

      # Loyverse Integration
      namespace :loyverse do
        # Webhooks
        resources :webhooks, only: [:create, :index] do
          member do
            post :retry
          end
        end

        # Receipts
        resources :receipts, only: [:index, :show] do
          collection do
            post :sync
          end
        end

        # Shifts
        resources :shifts, only: [:index, :show]

        # Configuration
        get 'config', to: 'config#show'
        patch 'config', to: 'config#update'

        # Payment Mappings
        post 'payment_mappings/sync', to: 'payment_mappings#sync'
        resources :payment_mappings, only: [:index, :update]
      end

      # Credit Cards & Debt
      resources :credit_cards do
        resources :credit_purchases, only: [:index, :create], shallow: true
      end

      resources :credit_purchases, only: [:show, :update, :destroy] do
        member do
          post :record_payment
        end
      end

      # Loans & Lenders
      resources :lenders do
        resources :loans, only: [:index, :create], shallow: true
      end

      resources :loans, only: [:show, :update, :destroy] do
        member do
          post :record_payment
        end
      end
    end
  end
end
