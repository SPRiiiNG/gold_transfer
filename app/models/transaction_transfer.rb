class TransactionTransfer < ApplicationRecord
  scope :allowed_asset_types, ->  { Asset.all.pluck(:name) }
  scope :allowed_transfer_type, -> { %w(add deduct) }

  belongs_to :transaction_parent, foreign_key: "transaction_id", class_name: "Transaction"
  belongs_to :balance

  validates :asset_type,
    presence: true,
    inclusion: { in: allowed_asset_types }

  validates :transfer_type,
    presence: true,
    inclusion: { in: allowed_transfer_type }

end
