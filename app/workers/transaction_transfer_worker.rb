class TransactionTransferWorker
  include Sidekiq::Worker

  def perform(transaction_id, income_amount)
    transaction = Transaction.find(transaction_id)
    case transaction.transaction_type
    when 'buy'
      transfer_buy = transaction.transfer_buy(transaction.asset_type, income_amount)
      transaction_transfer_cash = transaction.transaction_transfer('cash', 'deduct', transfer_buy[:deduct])
      transaction_transfer_cash.save      
      transaction_transfer_asset = transaction.transaction_transfer(transaction.asset_type, 'add', transfer_buy[:add])
      transaction_transfer_asset.save
      transaction.approve!
    when 'sell'
      transfer_sell = transaction.transfer_sell(transaction.asset_type, income_amount)      
      transaction_transfer_asset = transaction.transaction_transfer(transaction.asset_type, 'deduct', transfer_sell[:deduct])
      transaction_transfer_asset.save
      transaction_transfer_cash = transaction.transaction_transfer('cash', 'add', transfer_sell[:add])
      transaction_transfer_cash.save
      transaction.approve!
    when 'top_up'
      cash_amount = transaction.currency_to_cash(income_amount)
      transaction_transfer_cash = transaction.transaction_transfer('cash', 'add', cash_amount)
      transaction_transfer_cash.save
    when 'withdraw'
      transaction_transfer_cash = transaction.transaction_transfer('cash', 'deduct', income_amount)
      transaction_transfer_cash.save
    end
  end
end
