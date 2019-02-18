class CreateAssets < ActiveRecord::Migration[5.2]
  def change
    create_table :assets do |t|
      t.string :name
      t.decimal :amount, default: 0
      t.timestamps
    end
  end
end
