FactoryBot.define do
  factory :transaction do
    name { SecureRandom.base64(12) }
    income_amount { 0 }
    type { 'buy' }
    asset_type { 'cash' }
  end
end
