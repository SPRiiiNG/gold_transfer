require 'rails_helper'

RSpec.describe Asset, type: :model do
  describe "Validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe "Associations" do
    it { should have_many(:balances) }
  end
end
