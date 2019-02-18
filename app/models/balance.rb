class Balance < ApplicationRecord
  belongs_to :asset
  belongs_to :user
  has_many :transaction_transfers

  def asset_name
    self.asset.name
  end

  def amount
    add = self.transaction_transfers.where(asset_type: asset_name, transfer_type: 'add').sum(:amount)
    deduct = self.transaction_transfers.where(asset_type: asset_name, transfer_type: 'deduct').sum(:amount)
    add - deduct
  end
end
