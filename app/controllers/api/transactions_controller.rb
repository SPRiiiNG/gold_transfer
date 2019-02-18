module Api 
  class TransactionsController < ApiController

    def index
      render json: {transactions: Transaction.represent_all}
    end
  end
end