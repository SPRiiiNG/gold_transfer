require 'rails_helper'
RSpec.describe TransactionTransferWorker, type: :worker do
  let(:job)     { TransactionTransferWorker.new }
  let(:currency) { FactoryBot.create(:currency) }
  let(:user) { FactoryBot.create(:user, region: currency) }
  let(:asset_cash) { FactoryBot.create(:asset, name: 'cash') }
  let(:asset_gold) { FactoryBot.create(:asset, name: 'gold') }
  let(:transaction_top_up) { FactoryBot.build(:transaction, income_amount: 1000, transaction_type: 'top_up', asset_type: 'cash', user_id: user.id) }

  before do
    asset_cash
    asset_gold
    transaction_top_up.save
  end

  describe "#perform" do
    it "should relate to correct balance" do      
      job.perform(transaction_top_up.id, transaction_top_up.income_amount)
      cash_balance = user.balances.where(asset_id: asset_cash.id).first
      transaction_top_up.reload
      expect(transaction_top_up.transaction_transfers.first.amount).to eq(1000)
      expect(transaction_top_up.transaction_transfers.first.transfer_type).to eq('add')

      #after staff approve
      transaction_top_up.approve!
      expect(transaction_top_up.transaction_transfers.first.balance).to eq(cash_balance)
      expect(transaction_top_up.status).to eq('completed')
    end

    context "with asset type and approve" do
      before do
        #assign topup
        job.perform(transaction_top_up.id, transaction_top_up.income_amount)
        transaction_top_up.approve!
      end

      it "should relate to correct balance with withdraw" do
        transaction_withdraw = FactoryBot.build(:transaction, income_amount: 500, transaction_type: 'withdraw', user_id: user.id)
        transaction_withdraw.save
        job.perform(transaction_withdraw.id, transaction_withdraw.income_amount)
        transaction_withdraw.reload
        cash_balance = user.balances.where(asset_id: asset_cash.id).first
        
        expect(transaction_withdraw.transaction_transfers_by('cash').first.amount.to_f).to eq(500)
        expect(transaction_withdraw.transaction_transfers_by('cash').first.transfer_type).to eq('deduct')

        #after staff approved
        transaction_withdraw.approve!
        expect(transaction_withdraw.transaction_transfers_by('cash').first.balance).to eq(cash_balance)
        expect(transaction_withdraw.status).to eq('completed')
      end

      it "should relate to correct balance with buy gold" do
        transaction_buy = FactoryBot.build(:transaction, income_amount: 50, transaction_type: 'buy', asset_type: 'gold', user_id: user.id)
        transaction_buy.save
        job.perform(transaction_buy.id, transaction_buy.income_amount)

        cash_balance = user.balances.where(asset_id: asset_cash.id).first
        gold_balance = user.balances.where(asset_id: asset_gold.id).first
        transaction_buy.reload

        expect(transaction_buy.transaction_transfers_by('cash').first.balance).to eq(cash_balance)
        expect(transaction_buy.transaction_transfers_by('cash').first.amount.to_f).to eq(500)
        expect(transaction_buy.transaction_transfers_by('cash').first.transfer_type).to eq('deduct')

        expect(transaction_buy.transaction_transfers_by('gold').first.balance).to eq(gold_balance)
        expect(transaction_buy.transaction_transfers_by('gold').first.amount.to_f).to eq(50)
        expect(transaction_buy.transaction_transfers_by('gold').first.transfer_type).to eq('add')
        expect(transaction_buy.status).to eq('completed')
      end

      it "should relate to correct balance with sell gold" do
        transaction_buy = FactoryBot.build(:transaction, income_amount: 50, transaction_type: 'buy', asset_type: 'gold', user_id: user.id)
        transaction_buy.save
        job.perform(transaction_buy.id, transaction_buy.income_amount)

        transaction_sell = FactoryBot.build(:transaction, income_amount: 50, transaction_type: 'sell', asset_type: 'gold', user_id: user.id)
        transaction_sell.save
        job.perform(transaction_sell.id, transaction_sell.income_amount)
        transaction_sell.reload
        
        cash_balance = user.balances.where(asset_id: asset_cash.id).first
        gold_balance = user.balances.where(asset_id: asset_gold.id).first

        expect(transaction_sell.transaction_transfers_by('cash').first.balance).to eq(cash_balance)
        expect(transaction_sell.transaction_transfers_by('cash').first.amount.to_f).to eq(500)
        expect(transaction_sell.transaction_transfers_by('cash').first.transfer_type).to eq('add')

        expect(transaction_sell.transaction_transfers_by('gold').first.balance).to eq(gold_balance)
        expect(transaction_sell.transaction_transfers_by('gold').first.amount.to_f).to eq(50)
        expect(transaction_sell.transaction_transfers_by('gold').first.transfer_type).to eq('deduct')
        expect(transaction_sell.status).to eq('completed')
      end
    end
  end
end
