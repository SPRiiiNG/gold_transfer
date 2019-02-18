module Api 
  class TransactionsController < ApiController

    def index
      render json: {transactions: Transaction.represent_all}
    end

    def top_up
      transaction = initial_transaction(cash_params[:amount], 'top_up', 'cash')
      if transaction.save
        render json: { result: 'ok' }
      else
        render json: { message: transaction.errors.full_messages.join(',')}, status: 400
      end
    end

    def withdraw
      transaction = initial_transaction(cash_params[:amount], 'withdraw', 'cash')
      if transaction.save
        render json: { result: 'ok' }
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
    
  end
end