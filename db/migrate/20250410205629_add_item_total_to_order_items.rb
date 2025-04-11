class AddItemTotalToOrderItems < ActiveRecord::Migration[8.0]
  def change
    add_column :order_items, :item_total, :decimal
  end
end
