module Api
  module V1
    class AccountsController < ApplicationController
      # GET /api/v1/accounts
      def index
        accounts = Account.all
        render json: {
          accounts: accounts.as_json(only: [ :id, :name, :account_type, :current_balance, :description ]),
          total_balance: accounts.sum(:current_balance)
        }
      end

      # GET /api/v1/accounts/:id
      def show
        account = Account.find(params[:id])
        render json: {
          account: account.as_json(only: [ :id, :name, :account_type, :current_balance, :description ])
        }
      end

      # PATCH /api/v1/accounts/:id
      def update
        account = Account.find(params[:id])

        if account.update(account_params)
          render json: {
            account: account.as_json(only: [ :id, :name, :account_type, :current_balance, :description ]),
            message: "Cuenta actualizada exitosamente"
          }
        else
          render_error(account.errors.full_messages.join(", "))
        end
      end

      private

      def account_params
        params.require(:account).permit(:current_balance, :description)
      end
    end
  end
end
