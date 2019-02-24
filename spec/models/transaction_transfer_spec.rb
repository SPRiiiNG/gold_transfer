require 'rails_helper'

RSpec.describe TransactionTransfer, type: :model do

  describe "Validations" do
    let(:job)     { TransactionTransferWorker.new }
    let(:currency) { FactoryBot.create(:currency) }
    let(:user) { FactoryBot.create(:user, region: currency) }
    let(:asset_cash) { FactoryBot.create(:asset, name: 'cash') }
    let(:transaction_top_up) { FactoryBot.build(:transaction, income_amount: 1000, transaction_type: 'top_up', asset_type: 'cash', user_id: user.id) }
    let(:transaction_transfer) { FactoryBot.build(:transaction_transfer, transaction_parent: transaction_top_up) }
    
    before do
      asset_cash
      transaction_top_up.save
      job.perform(transaction_top_up.id, transaction_top_up.income_amount)
    end

    it { is_expected.to validate_presence_of(:asset_type) }
    it { is_expected.to validate_presence_of(:transfer_type) }
    # it { is_expected.to validate_uniqueness_of(:transfer_type).scoped_to(:transaction_parent) }

    context "asset_type: uniquness scoped to transaction_parent" do
      it "should valid" do
        transaction_transfer.asset_type = 'silver'
        expect(transaction_transfer.valid?).to eq(true)
        expect(transaction_transfer.errors.messages).to be_blank
      end

      it "should not valid" do
        expect(transaction_transfer.valid?).to eq(false)
        expect(transaction_transfer.errors.messages[:asset_type]).to eq(['has already been taken'])
      end
    end

    context "transfer_type: inclusion in allowed_transfer_type" do
      it "should valid" do
        transaction_transfer.asset_type = 'silver'
        expect(transaction_transfer.valid?).to eq(true)
        expect(transaction_transfer.errors.messages).to be_blank
      end

      it "should not valid" do
        transaction_transfer.asset_type = 'silver'
        transaction_transfer.transfer_type = 'plus'
        expect(transaction_transfer.valid?).to eq(false)
        expect(transaction_transfer.errors.messages[:transfer_type]).to eq(["is not included in the list"])
      end
    end
  end

  describe "Associations" do
    it { should belong_to(:transaction_parent).class_name('Transaction') }
    it { should have_db_column(:transaction_id) }
    it { should belong_to(:balance).optional }
    it { should have_db_column(:balance_id) }
  end
end
