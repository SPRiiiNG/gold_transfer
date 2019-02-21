require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  let(:staff) { FactoryBot.create(:staff) }
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


  describe "GET" do
    describe "#index" do
      it "should render successful after sign in as staff" do
        sign_in_as(staff) do
          get :index
          expect(response).to be_successful
        end
      end

      it "should render failured after sign in as user" do
        sign_in_as(user) do
          get :index
          expect(response).not_to be_successful
        end
      end
    end
  end

  describe "PUT/PATCH" do
    let(:transaction_top_up_1) { FactoryBot.build(:transaction, income_amount: 1000, transaction_type: 'top_up', asset_type: 'cash', user_id: user.id) }

    before do
      transaction_top_up_1.save
    end

    describe "#approve" do        
      it "should approve transaction successfully" do
        sign_in_as(staff) do
          put :approve, 
          params: { 
            id: transaction_top_up_1.id
          }
          transaction_top_up_1.reload
          expect(transaction_top_up_1.status).to eq('completed')
          expect(response).to redirect_to(transactions_path)
        end
      end

      it "should approve transaction failured" do
        sign_in_as(staff) do
          put :approve, 
          params: { 
            id: 999
          }
          transaction_top_up_1.reload
          expect(transaction_top_up_1.status).to eq('pending')
          expect(response).to redirect_to(transactions_path)
        end
      end
    end

    describe "#reject" do        
      it "should reject transaction successfully" do
        sign_in_as(staff) do
          put :reject, 
          params: { 
            id: transaction_top_up_1.id
          }
          transaction_top_up_1.reload
          expect(transaction_top_up_1.status).to eq('rejected')
          expect(response).to redirect_to(transactions_path)
        end
      end

      it "should reject transaction failured" do
        sign_in_as(staff) do
          put :reject, 
          params: { 
            id: 999
          }
          transaction_top_up_1.reload
          expect(transaction_top_up_1.status).to eq('pending')
          expect(response).to redirect_to(transactions_path)
        end
      end
    end
  end
end
