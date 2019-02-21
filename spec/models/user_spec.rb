require 'rails_helper'

RSpec.describe User, type: :model do
  let(:currency) { FactoryBot.create(:currency) }
  let(:asset_cash) { FactoryBot.create(:asset, name: 'cash') }
  let(:asset_gold) { FactoryBot.create(:asset, name: 'gold') }
  let(:user) { FactoryBot.create(:user, region: currency) }

  describe "Associations" do
    it { should have_many(:authentication_tokens).dependent(:destroy) }
    it { should have_many(:transactions) }
    it { should have_many(:balances) }
    it { should belong_to(:region).class_name('Currency') }
    it { should have_db_column(:currency_id) }
  end

  describe "Callbacks" do
    describe "#generate_balance_by_assets" do
      it "should generate balance by assets" do
        asset_cash
        asset_gold
        user
        expect(user.balances.count).to eq(2)
        asset_names = user.balances.map{|balance| balance.asset_name}
        expect(asset_names.sort).to eq(Asset.all.pluck(:name).sort)
      end

      it "should generate balance after asset has been created" do
        asset_cash
        asset_gold
        user
        asset_silver = FactoryBot.create(:asset, name: 'silver')
        user.update(current_sign_in_at: Time.now)
        expect(user.balances.count).to eq(3)
        asset_names = user.balances.map{|balance| balance.asset_name}
        expect(asset_names.sort).to eq(Asset.all.pluck(:name).sort) 
      end
    end
  end
end
