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

      resources :payment_methods

      resources :reimbursements, only: [:index, :create, :show]

      # Credit Cards & Debt
      resources :credit_cards do
        collection do
          get :summary
        end
      end

      resources :credit_purchases do
        member do
          post :record_payment
          post :mark_as_paid
        end
        collection do
          get :summary
        end
      end

      # Loans
      resources :lenders do
        collection do
          get :summary
        end
      end

      resources :loans do
        member do
          post :record_payment
          post :mark_as_paid
        end
        collection do
          get :summary
        end
      end

      # Dashboard
      namespace :dashboard do
        get :summary, to: 'summary#index'
        get :profitability, to: 'profitability#index'
        get :break_even, to: 'break_even#index'
        get :cash_flow, to: 'cash_flow#index'
        get :expense_breakdown, to: 'expense_breakdown#index'
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

  # Swagger/OpenAPI Documentation
  # UI accesible en: http://localhost:3000/api-docs
  # API spec en: http://localhost:3000/api-docs/v1/swagger.yaml
  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'
end
