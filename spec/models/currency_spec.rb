require 'rails_helper'

RSpec.describe Currency, type: :model do
  let(:user) { FactoryBot.build(:user) }
  let(:currency) { FactoryBot.create(:currency) }

  describe "Validations" do
    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_uniqueness_of(:code) }
  end

  describe "Methods" do
    describe "#add_user" do
      it "should add user successfully" do
        currency.add_user(user)
        expect(user.reload.region).to eq(currency)
      end
    end
  end
end
