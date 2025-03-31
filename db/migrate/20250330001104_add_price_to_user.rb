class AddPriceToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :price, :decimal
  end
end
