require 'rails_helper'
require 'fake_request'

RSpec.describe 'Transactions API', type: :request do
  let(:currency) { FactoryBot.create(:currency) }
  let(:user)      { FactoryBot.create(:user, region: currency) }
  let(:asset_cash) { FactoryBot.create(:asset, name: 'cash') }
  let(:asset_gold) { FactoryBot.create(:asset, name: 'gold') }
  let(:transaction_top_up) { FactoryBot.build(:transaction, income_amount: 1000, transaction_type: 'top_up', asset_type: 'cash', user_id: user.id) }
  let(:token) { Tiddle.create_and_return_token(user, FakeRequest.new) }

  before do
    asset_cash
    asset_gold
    transaction_top_up.save
  end

  describe "#index" do
    it "should return transactions" do
      get api_transactions_path,
      headers: {
        "X-USER-EMAIL" => user.email,
        "X-USER-TOKEN" => token
      }
      data = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(data['transactions'].first['id']).to eq(transaction_top_up.id)
      expect(data['transactions'].first['name']).to eq(transaction_top_up.name)
      expect(data['transactions'].first['type']).to eq(transaction_top_up.transaction_type)
      expect(data['transactions'].first['asset']).to eq(transaction_top_up.asset_type)
      expect(data['transactions'].first['amount']).to eq(transaction_top_up.transaction_transfers_by('cash').first.amount.to_s)
    end

    it "should return unauthorized" do
      get api_transactions_path
      expect(response.status).to eq(401)
    end
  end

  describe "#top_up" do
    it "should top up successfully" do
      post api_transactions_top_up_path,
      headers: {
        "X-USER-EMAIL" => user.email,
        "X-USER-TOKEN" => token
      },
      params: {
        amount: 999
      }
      data = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(data['result']).to eq('ok')
      cash_balance = user.balances.where(asset_id: asset_cash.id).first
      expect(cash_balance.amount.to_f).to eq(1999)
    end

    it "should top up failured" do
      post api_transactions_top_up_path,
      headers: {
        "X-USER-EMAIL" => user.email,
        "X-USER-TOKEN" => token
      },
      params: {
        amount: 'eiei'
      }
      data = JSON.parse(response.body)
      expect(response.status).to eq(400)
      expect(data['message']).to be_present
      cash_balance = user.balances.where(asset_id: asset_cash.id).first
      expect(cash_balance.amount.to_f).to eq(1000)
    end
  end

  describe "#withdraw" do
    it "should withdraw successfully" do
      post api_transactions_withdraw_path,
      headers: {
        "X-USER-EMAIL" => user.email,
        "X-USER-TOKEN" => token
      },
      params: {
        amount: 999
      }
      data = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(data['result']).to eq('ok')
      cash_balance = user.balances.where(asset_id: asset_cash.id).first
      expect(cash_balance.amount.to_f).to eq(1)
    end

    it "should withdraw failured" do
      post api_transactions_withdraw_path,
      headers: {
        "X-USER-EMAIL" => user.email,
        "X-USER-TOKEN" => token
      },
      params: {
        amount: 'eiei'
      }
      data = JSON.parse(response.body)
      expect(response.status).to eq(400)
      expect(data['message']).to be_present
      cash_balance = user.balances.where(asset_id: asset_cash.id).first
      expect(cash_balance.amount.to_f).to eq(1000)
    end

    it "should withdraw failured if withdraw more than cash balance" do
      post api_transactions_withdraw_path,
      headers: {
        "X-USER-EMAIL" => user.email,
        "X-USER-TOKEN" => token
      },
      params: {
        amount: 2000
      }
      data = JSON.parse(response.body)
      expect(response.status).to eq(400)
      expect(data['message']).to be_present
      cash_balance = user.balances.where(asset_id: asset_cash.id).first
      expect(cash_balance.amount.to_f).to eq(1000)
    end
  end
end
