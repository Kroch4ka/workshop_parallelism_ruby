class TopProductsSerializer < ActiveModel::Serializer
  attributes :product_id, :date, :total_quantity

  def product_id = self.object.id
  def total_quantity = self.object.orders_count
  def date = self.object.date.strftime("%d-%m-%Y")
end
