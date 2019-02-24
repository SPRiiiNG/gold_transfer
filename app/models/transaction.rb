class Transaction < ApplicationRecord
  include AASM

  scope :allowed_types, ->  { %w(buy sell top_up withdraw) }
  attr_accessor :income_amount

  belongs_to :user
  has_many :transaction_transfers

  validates :transaction_type,
    presence: true,
    inclusion: { in: allowed_types }

  validates :asset_type,
    presence: true

  validates :income_amount,
    presence: true,
    numericality: { greater_than_or_equal_to: 0 }, if: Proc.new{ |obj| obj.new_record? }

  validate :asset_type_inclusion
  validate :cash_enough, :if => Proc.new { |record| %w(buy withdraw).include?(record.transaction_type)}
  validate :asset_enough, :if => Proc.new { |record| record.transaction_type == 'sell'}
  
  before_validation :generate_name
  after_create :create_transfers

  scope :by_cash, ->  { Transaction.where(asset_type: 'cash') }

  aasm column: :status do
    state :pending, :initial => true
    state :completed
    state :rejected

    event :approve do
      after do
        self.relate_to_balance
      end
      transitions :from => :pending, :to => :completed
    end

    event :reject do
      transitions :from => :pending, :to => :rejected
    end
  end

  def create_transfers
    TransactionTransferWorker.perform_async(self.id, self.income_amount)
  end

  def asset_balance(user, asset_type='cash')
    asset = Asset.where(name: asset_type).first
    asset_balance = user.balances.where(asset_id: asset.id).first || user.create_balance_by(asset)
    return asset_balance
  end

  def transfer_buy(asset_type, asset_amount)
    deduct = asset_type.eql?('cash') ? asset_amount.to_f : asset_amount.to_f * 10
    {
      add: asset_amount.to_f,
      deduct: deduct
    }
  end

  def transfer_sell(asset_type, asset_amount)
    add = asset_type.eql?('cash') ? asset_amount.to_f : asset_amount.to_f * 10
    {
      add: add,
      deduct: asset_amount.to_f
    }
  end

  def currency_to_cash(income_amount)
    currency_rate = self.user.region.reload&.top_up_rate
    income_amount * currency_rate
  end

  def transaction_transfers_by(asset_type)
    self.transaction_transfers.where(asset_type: asset_type)
  end

  def self.allowed_asset_types
    Asset.all.pluck(:name)
  end

  def self.represent_all
    # Transaction.select("id, name, asset_type as asset, transaction_type as type")
    Transaction.includes(:transaction_transfers).all.map do |transaction|
      {
        "id" => transaction.id,
        "name" => transaction.name,
        "type" => transaction.transaction_type,
        "asset" => transaction.asset_type,
        "amount" => transaction.transaction_transfers_by(transaction.asset_type).first.amount
      }
    end
  end

  def relate_to_balance
    self.transaction_transfers.each do |transfer|
      balance = asset_balance(self.user, transfer.asset_type)
      transfer.balance = balance
      transfer.save
    end
  end

  def transaction_transfer(asset_type, transfer_type, amount)
    TransactionTransfer.new(
      transaction_parent: self,
      asset_type: asset_type, 
      transfer_type: transfer_type,
      amount: amount
    )
  end

  private 

  def asset_type_inclusion
    allowed_asset_types = Transaction.allowed_asset_types
    unless allowed_asset_types.include? self.asset_type
      errors.add(:asset_type, "asset type not in #{allowed_asset_types}")
    end
  end

  def cash_enough
    cash_balance = asset_balance(self.user)
    transfer_buy = self.transaction_type == 'buy' ? transfer_buy(self.asset_type, income_amount)[:deduct] : income_amount
    if transfer_buy.to_f > cash_balance.amount
      errors.add("balance", "cash not enough, cash total: #{transfer_buy}, cash amount: #{cash_balance.amount}")
    end
  end

  def asset_enough
    asset_balance = asset_balance(self.user, self.asset_type)
    if self.income_amount.to_f > asset_balance.amount
      errors.add("balance", "#{self.asset_type} not enough, #{self.asset_type} total: #{self.income_amount}, #{self.asset_type} amount: #{asset_balance.amount}")
    end
  end

  def generate_name
    self.name = SecureRandom.base64(12)
  end
end
