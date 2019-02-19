module Api 
  class TransactionsController < ApiController

    def index
      render json: {transactions: Transaction.represent_all}
    end

    def top_up
      transaction = initial_transaction(cash_params[:amount], 'top_up', 'cash')
      if transaction.save
        render json: { result: 'ok', name: transaction.name }
      else
        render json: { message: transaction.errors.full_messages.join(',')}, status: 400
      end
    end

    def withdraw
      transaction = initial_transaction(cash_params[:amount], 'withdraw', 'cash')
      if transaction.save
        render json: { result: 'ok', name: transaction.name }
      else
        render json: { message: transaction.errors.full_messages.join(',')}, status: 400
      end
    end

    def buy
      transaction = initial_transaction(asset_params[:amount], 'buy', asset_params[:asset])
      if transaction.save
        render json: { result: 'ok', name: transaction.name }
      else
        render json: { message: transaction.errors.full_messages.join(',')}, status: 400
      end
    end

    def sell
      transaction = initial_transaction(asset_params[:amount], 'sell', asset_params[:asset])
      if transaction.save
        render json: { result: 'ok', name: transaction.name }
      else
        render json: { message: transaction.errors.full_messages.join(',')}, status: 400
      end
    end

    private
    def initial_transaction(amount, type, asset)
      transaction = Transaction.new(
        income_amount: amount,
        transaction_type: type,
        asset_type: asset,
        user_id: current_api_user.id
      )
    end

    def cash_params
      params.permit(:amount)
    end
    
    def asset_params
      params.permit(:amount, :asset)
    end
  end
end