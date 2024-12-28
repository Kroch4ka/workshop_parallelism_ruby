class AddOrdersCountToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :orders_count, :integer, default: 0, null: false
  end
end
