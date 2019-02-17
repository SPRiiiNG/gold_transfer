FactoryBot.define do
  factory :authentication_token do
    body {"MyString"}
    user {nil}
    last_used_at {"2019-02-17 00:36:01"}
    expires_in {1}
    ip_address {"MyString"}
    user_agent {"MyString"}
  end
end
