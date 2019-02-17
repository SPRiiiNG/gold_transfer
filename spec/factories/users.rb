FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { "#{last_name}.#{first_name}@example.com" }
    password { "123456789" }
    password_confirmation { "123456789" }
  end
end
