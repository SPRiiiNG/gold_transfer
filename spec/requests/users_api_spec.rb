require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  describe "#create" do
    let(:currency) { FactoryBot.create(:currency) }
    let(:user)      { FactoryBot.create(:user, region: currency) }

    it "should return status 201" do
      post api_register_path,
      params: {
        email: "test.nakrub@example.com",
        password: "123456789",
        password_confirmation: "123456789",
        first_name: "Test",
        last_name: "Nakrub",
        region: currency.code
      }
      expect(response.status).to eq(201)
    end

    it "should return status 200 and message if user is already exists" do
      post api_register_path,
      params: {
        email: user.email,
        password: "123456789",
        password_confirmation: "123456789",
        first_name: "Test",
        last_name: "Nakrub",
        region: currency.code
      }
      data = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(data['message']).to match(/Email has already been taken/)
    end

    it "should return status 200 and message incorrect region" do
      post api_register_path,
      params: {
        email: "aa@example.com",
        password: "123456789",
        password_confirmation: "123456789",
        first_name: "Test",
        last_name: "Nakrub",
        region: 'cn'
      }
      data = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(data['message']).to match(/Region must exist/)
    end
  end
end
