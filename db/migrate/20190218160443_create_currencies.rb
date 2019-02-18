class CreateCurrencies < ActiveRecord::Migration[5.2]
  def change
    create_table :currencies do |t|
      t.decimal :top_up_rate
      t.decimal :withdraw_rate
      t.string :name
      t.string :code
      t.timestamps
    end
  end
end
