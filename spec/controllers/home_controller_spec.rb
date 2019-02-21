require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  let(:staff) { FactoryBot.create(:staff) }
  let(:currency) { FactoryBot.create(:currency) }
  let(:user) { FactoryBot.create(:user, region: currency) }

  describe "GET" do
    describe "#welcome" do
      it "should render successful after sign in as staff" do
        sign_in_as(staff) do
          get :welcome
          expect(response).to be_successful
        end
      end

      it "should render failured after sign in as user" do
        sign_in_as(user) do
          get :welcome
          expect(response).not_to be_successful
        end
      end
    end
  end
end
