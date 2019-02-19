class Asset < ApplicationRecord
  has_many :balances
  validates :name,
    presence: true,
    uniqueness: true
end
