FactoryBot.define do
  factory :transaction_transfer do
    asset_type { 'cash' }
    transfer_type { 'add' }
  end
end
