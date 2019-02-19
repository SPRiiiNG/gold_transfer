require 'rails_helper'
require 'fake_request'

RSpec.describe 'Balances API', type: :request do
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
    transaction_top_up.approve!
  end

  describe "#show" do
    it "return balances successfully" do
      get api_balance_path,
      headers: {
        "X-USER-EMAIL" => user.email,
        "X-USER-TOKEN" => token
      }
      data = JSON.parse(response.body)  
      expect(response.status).to eq(200)
      expect(data[asset_cash.name].to_f).to eq(1000)
      expect(data[asset_gold.name].to_f).to eq(0)
    end

    it "return balances correctly" do
      transaction_buy = FactoryBot.build(:transaction, income_amount: 50, transaction_type: 'buy', asset_type: 'gold', user_id: user.id)
      transaction_buy.save
      get api_balance_path,
      headers: {
        "X-USER-EMAIL" => user.email,
        "X-USER-TOKEN" => token
      }
      data = JSON.parse(response.body)  
      expect(response.status).to eq(200)
      expect(data[asset_cash.name].to_f).to eq(500)
      expect(data[asset_gold.name].to_f).to eq(50)
    end
  end

end