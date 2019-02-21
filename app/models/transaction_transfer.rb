class TransactionTransfer < ApplicationRecord
  scope :allowed_transfer_type, -> { %w(add deduct) }

  belongs_to :transaction_parent, foreign_key: "transaction_id", class_name: "Transaction"
  belongs_to :balance, optional: true

  validates :asset_type,
    presence: true,
    uniqueness: { scope: :transaction_parent}

  validates :transfer_type,
    presence: true,
    inclusion: { in: allowed_transfer_type }

end
