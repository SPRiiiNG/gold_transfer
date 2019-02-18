class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.string :name
      t.references :user, foreign_key: true
      t.string :type
      t.string :asset_type
      t.timestamps
    end
  end
end
