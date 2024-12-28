class OrdersController < ApplicationController
  def top_products_report
    top_products = ProductsByOrdersCount.new.call
    render json: top_products, each_serializer: TopProductsSerializer
  end
end
