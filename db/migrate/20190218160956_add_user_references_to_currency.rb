class AddUserReferencesToCurrency < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :currency, index: true
  end
end
