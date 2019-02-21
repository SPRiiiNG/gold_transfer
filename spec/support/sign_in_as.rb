module SignInAs
  def sign_in_as(user = FactoryBot.create(:staff))
    begin
      token = sign_in user
      yield token
    ensure
      sign_out :users
    end
  end
end
