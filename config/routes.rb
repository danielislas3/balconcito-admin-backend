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
        get :summary
        get :profitability
        get :break_even
        get :cash_flow
        get :expense_breakdown
        get 'debt', to: 'debt#index'
        get 'debt/partners_capital', to: 'debt#partners_capital'
      end

      # Loyverse Integration
      namespace :loyverse do
        resources :webhooks, only: [:create, :index] do
          member do
            post :retry
          end
        end

        resources :receipts, only: [:index, :show] do
          collection do
            post :sync
          end
        end

        get 'config', to: 'config#show'
        patch 'config', to: 'config#update'
        post 'payment_mappings/sync', to: 'payment_mappings#sync'
        resources :payment_mappings, only: [:index, :update]
      end
    end
  end
end
