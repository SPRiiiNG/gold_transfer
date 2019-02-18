FactoryBot.define do
  factory :currency do
    name { "Thai" }
    code { "th" }
    top_up_rate { 1 }
    withdraw_rate { 1 }
  end
end
