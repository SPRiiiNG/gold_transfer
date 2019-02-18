require 'rails_helper'
require 'fake_request'

RSpec.describe 'Transactions API', type: :request do
  describe "#index" do
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
end
