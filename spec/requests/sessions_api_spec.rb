require 'rails_helper'

RSpec.describe 'Sessions API', type: :request do
  describe "#create" do
    let(:user)      { FactoryBot.create(:user) }

    it "should return token and status 200" do
      post api_user_session_path,
      params: {
        api_user: {
          email: user.email,
          password: "123456789"
        }
      }
      data = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(data['authentication_token']).to be_present
      expect(data['authentication_token']).to be_kind_of(String)
    end

    it "should return status 401 if password is incorrect" do
      post api_user_session_path,
      params: {
        api_user: {
          email: user.email,
          password: "1234567890"
        }
      }
      expect(response.status).to eq(401)
    end
  end
end
