class CreateBalances < ActiveRecord::Migration[5.2]
  def change
    create_table :balances do |t|
      t.references :user, foreign_key: true
      t.references :asset, foreign_key: true
      t.timestamps
    end
  end
end
