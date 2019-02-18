class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :token_authenticatable

  has_many :authentication_tokens
  has_many :transactions
  has_many :balances, dependent: :destroy
  belongs_to :region, foreign_key: "currency_id", class_name: "Currency"

  after_save :generate_balance_by_assets


  def generate_balance_by_assets
    current_balance_asset_ids = self.balances.pluck(:asset_id)
    asset_ids = Asset.all.pluck(:id)
    new_asset_ids = asset_ids - current_balance_asset_ids
    
    if new_asset_ids.present?
      data = new_asset_ids.map do |asset_id|
        {
          user_id: self.id,
          asset_id: asset_id
        }
      end
      Balance.create(data)
    end
  end

  def create_balance_by(asset)
    balance = Balance.new(user_id: self.id, asset_id: asset.id)
    return (balance.save ? balance : nil)
  end
  
end
