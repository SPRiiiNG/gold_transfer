require 'rails_helper'

RSpec.describe Balance, type: :model do
  let(:currency) { FactoryBot.create(:currency) }
  let(:user) { FactoryBot.create(:user, region: currency) }
  let(:asset_cash) { FactoryBot.create(:asset, name: 'cash') }
  let(:asset_gold) { FactoryBot.create(:asset, name: 'gold') }
  let(:transaction_top_up) { FactoryBot.build(:transaction, income_amount: 1000, transaction_type: 'top_up', user_id: user.id) }

  before do
    asset_cash
    asset_gold
    transaction_top_up.save
    transaction_top_up.approve!
  end

  describe "Methods" do
    describe "#amount" do
      it "return amount correctly after top up" do
        cash_balance = user.balances.where(asset_id: asset_cash.id).first
        expect(cash_balance.amount.to_f).to eq(1000)
      end

      it "return amount correctly after withdraw" do
        cash_balance = user.balances.where(asset_id: asset_cash.id).first
        transaction_withdraw = FactoryBot.build(:transaction, income_amount: 500, transaction_type: 'withdraw', user_id: user.id)
        transaction_withdraw.save
        transaction_withdraw.approve!
        expect(cash_balance.amount.to_f).to eq(500)
      end

      it "return amount correctly after buy and sell" do
        cash_balance = user.balances.where(asset_id: asset_cash.id).first
        gold_balance = user.balances.where(asset_id: asset_gold.id).first

        transaction_buy = FactoryBot.build(:transaction, income_amount: 50, transaction_type: 'buy', asset_type: 'gold', user_id: user.id)
        transaction_buy.save
        expect(cash_balance.amount.to_f).to eq(500)
        expect(gold_balance.amount.to_f).to eq(50)

        transaction_sell = FactoryBot.build(:transaction, income_amount: 20, transaction_type: 'sell', asset_type: 'gold', user_id: user.id)
        transaction_sell.save
        expect(cash_balance.amount.to_f).to eq(700)
        expect(gold_balance.amount.to_f).to eq(30)
      end
    end
  end
end
