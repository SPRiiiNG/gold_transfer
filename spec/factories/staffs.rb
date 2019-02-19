FactoryBot.define do
  factory :staff do
    email { "admin@example.com" }
    password { "123456789" }
    password_confirmation { "123456789" }
  end
end
