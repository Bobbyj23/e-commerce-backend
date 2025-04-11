class RemoveItemTotalFromOrderItems < ActiveRecord::Migration[8.0]
  def change
    remove_column :order_items, :item_total, :decimal
  end
end
