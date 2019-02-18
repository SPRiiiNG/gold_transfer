module Api 
  class BalancesController < ApiController
    def show
      balances = Balance.where(user_id: current_api_user.id)
      .includes(:asset, :transaction_transfers)
      .inject({}) do |hash, balance|
        hash[balance.asset_name] = balance.amount
        hash
      end

      render json: balances
    end
  end
end