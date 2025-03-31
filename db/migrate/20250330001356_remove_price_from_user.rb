class RemovePriceFromUser < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :price, :decimal
  end
end
