require 'rails_helper'

RSpec.describe Transaction, type: :model do
  let(:currency) { FactoryBot.create(:currency) }
  let(:user) { FactoryBot.create(:user, region: currency) }
  let(:asset_cash) { FactoryBot.create(:asset, name: 'cash') }
  let(:asset_gold) { FactoryBot.create(:asset, name: 'gold') }
  let(:transaction_top_up) { FactoryBot.build(:transaction, income_amount: 1000, transaction_type: 'top_up', asset_type: 'cash', user_id: user.id) }

  before do
    asset_cash
    asset_gold
    transaction_top_up.save
    transaction_top_up.approve!
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:transaction_type) }
    it { is_expected.to validate_presence_of(:asset_type) }
    it { is_expected.to validate_presence_of(:income_amount) }
    it { is_expected.to validate_numericality_of(:income_amount) }

    describe "#cash_enough" do
      it "should create withdraw transaction successfully" do
        transaction_withdraw = FactoryBot.build(:transaction, income_amount: 500, transaction_type: 'withdraw', user_id: user.id)
        transaction_withdraw.save
        expect(transaction_withdraw.transaction_transfers_by('cash').first).to be_present
        expect(transaction_withdraw.transaction_transfers_by('cash').first.transfer_type).to eq('deduct')
      end

      it "should create withdraw transaction failured" do
        transaction_withdraw = FactoryBot.build(:transaction, income_amount: 1500, transaction_type: 'withdraw', user_id: user.id)
        transaction_withdraw.save
        puts transaction_withdraw.errors.messages
        expect(transaction_withdraw.errors.messages).to be_present
        expect(transaction_withdraw.transaction_transfers_by('cash').first).to be_blank
      end

      it "should create buy transaction successfully with asset" do
        transaction_buy = FactoryBot.build(:transaction, income_amount: 50, transaction_type: 'buy', asset_type: 'gold', user_id: user.id)
        transaction_buy.save
        expect(transaction_buy.transaction_transfers_by('cash').first).to be_present
        expect(transaction_buy.transaction_transfers_by('cash').first.transfer_type).to eq('deduct')

        expect(transaction_buy.transaction_transfers_by('gold').first).to be_present
        expect(transaction_buy.transaction_transfers_by('gold').first.transfer_type).to eq('add')
      end

      it "should create buy transaction failured with asset" do
        transaction_buy = FactoryBot.build(:transaction, income_amount: 200, transaction_type: 'buy', asset_type: 'gold', user_id: user.id)
        transaction_buy.save
        expect(transaction_buy.errors.messages).to be_present
        expect(transaction_buy.transaction_transfers).to be_blank
      end
    end

    describe "#asset_enough" do
      it "should create sell transaction successfully" do
        transaction_buy = FactoryBot.build(:transaction, income_amount: 50, transaction_type: 'buy', asset_type: 'gold', user_id: user.id)
        transaction_buy.save
        transaction_sell = FactoryBot.build(:transaction, income_amount: 20, asset_type: 'gold', transaction_type: 'sell', user_id: user.id)
        transaction_sell.save

        expect(transaction_sell.transaction_transfers_by('cash').first).to be_present
        expect(transaction_sell.transaction_transfers_by('cash').first.transfer_type).to eq('add')
        expect(transaction_sell.transaction_transfers_by('gold').first).to be_present
        expect(transaction_sell.transaction_transfers_by('gold').first.transfer_type).to eq('deduct')
      end

      it "should create sell transaction failured" do
        transaction_sell = FactoryBot.build(:transaction, income_amount: 20, asset_type: 'gold', transaction_type: 'sell', user_id: user.id)
        transaction_sell.save
        expect(transaction_sell.errors.messages).to be_present
        expect(transaction_sell.transaction_transfers).to be_blank
      end
    end
  end

  describe "Methods" do
    describe "#asset_balance" do
      it "should return balance from new asset correctly" do
        asset_silver = FactoryBot.create(:asset, name: 'silver')
        transaction_buy = FactoryBot.build(:transaction, income_amount: 10, transaction_type: 'buy', asset_type: 'silver', user_id: user.id)
        asset_balance = transaction_buy.asset_balance(transaction_buy.user, asset_silver.name)
        expect(asset_balance.user).to eq(user)
        expect(asset_balance.asset_id).to eq(asset_silver.id)
      end
    end
  end

  describe "Callbakcs" do
    describe "#create_transfers" do
      it "should relate to correct balance" do        
        cash_balance = user.balances.where(asset_id: asset_cash.id).first
        expect(transaction_top_up.transaction_transfers.first.balance).to eq(cash_balance)
        expect(transaction_top_up.transaction_transfers.first.amount).to eq(1000)
        expect(transaction_top_up.transaction_transfers.first.transfer_type).to eq('add')
        expect(transaction_top_up.status).to eq('completed')
      end

      context "with asset type and approve" do
        it "should relate to correct balance with withdraw" do
          transaction_withdraw = FactoryBot.build(:transaction, income_amount: 500, transaction_type: 'withdraw', user_id: user.id)
          transaction_withdraw.save
          transaction_withdraw.approve!
          cash_balance = user.balances.where(asset_id: asset_cash.id).first
          expect(transaction_withdraw.transaction_transfers_by('cash').first.balance).to eq(cash_balance)
          expect(transaction_withdraw.transaction_transfers_by('cash').first.amount.to_f).to eq(500)
          expect(transaction_withdraw.transaction_transfers_by('cash').first.transfer_type).to eq('deduct')
          expect(transaction_withdraw.status).to eq('completed')
        end

        it "should relate to correct balance with buy gold" do
          transaction_buy = FactoryBot.build(:transaction, income_amount: 50, transaction_type: 'buy', asset_type: 'gold', user_id: user.id)
          transaction_buy.save
          cash_balance = user.balances.where(asset_id: asset_cash.id).first
          gold_balance = user.balances.where(asset_id: asset_gold.id).first

          expect(transaction_buy.transaction_transfers_by('cash').first.balance).to eq(cash_balance)
          expect(transaction_buy.transaction_transfers_by('cash').first.amount.to_f).to eq(500)
          expect(transaction_buy.transaction_transfers_by('cash').first.transfer_type).to eq('deduct')

          expect(transaction_buy.transaction_transfers_by('gold').first.balance).to eq(gold_balance)
          expect(transaction_buy.transaction_transfers_by('gold').first.amount.to_f).to eq(50)
          expect(transaction_buy.transaction_transfers_by('gold').first.transfer_type).to eq('add')
        end

        it "should relate to correct balance with sell gold" do
          transaction_buy = FactoryBot.build(:transaction, income_amount: 50, transaction_type: 'buy', asset_type: 'gold', user_id: user.id)
          transaction_buy.save
          transaction_sell = FactoryBot.build(:transaction, income_amount: 50, transaction_type: 'sell', asset_type: 'gold', user_id: user.id)
          transaction_sell.save
          cash_balance = user.balances.where(asset_id: asset_cash.id).first
          gold_balance = user.balances.where(asset_id: asset_gold.id).first

          expect(transaction_sell.transaction_transfers_by('cash').first.balance).to eq(cash_balance)
          expect(transaction_sell.transaction_transfers_by('cash').first.amount.to_f).to eq(500)
          expect(transaction_sell.transaction_transfers_by('cash').first.transfer_type).to eq('add')

          expect(transaction_sell.transaction_transfers_by('gold').first.balance).to eq(gold_balance)
          expect(transaction_sell.transaction_transfers_by('gold').first.amount.to_f).to eq(50)
          expect(transaction_sell.transaction_transfers_by('gold').first.transfer_type).to eq('deduct')
        end
      end
    end
  end
end
