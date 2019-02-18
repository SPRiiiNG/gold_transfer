class CreateTransactionTransfers < ActiveRecord::Migration[5.2]
  def change
    create_table :transaction_transfers do |t|
      t.references :transaction, foreign_key: true
      t.references :balance, foreign_key: true
      t.decimal :amount, default: 0
      t.string :asset_type
      t.string :transfer_type
      t.timestamps
    end
  end
end
