class ProductsByOrdersCount
  def initialize(count: 10)
    @count = count
  end

  def call
    sanitized_sql = ActiveRecord::Base.sanitize_sql_array([sql, count, count])
    Product.find_by_sql(sanitized_sql)
  end

  private

  attr_reader :count

  def sql
    @sql ||= <<-SQL.squish
      WITH top_products AS (
        SELECT *
        FROM products
        ORDER BY orders_count DESC
        LIMIT ?
      ),
      max_days AS (
        SELECT product_id, DATE(created_at) AS order_date, SUM(quantity) AS daily_quantity
        FROM orders
        WHERE product_id IN (SELECT product_id FROM top_products)
        GROUP BY product_id, DATE(created_at)
      ),
      max_days_per_product AS (
        SELECT product_id, order_date, daily_quantity,
              RANK() OVER (PARTITION BY product_id ORDER BY daily_quantity DESC) as rank
        FROM max_days
      )
      
      SELECT t.*, m.order_date as date
      FROM max_days_per_product as m
      JOIN top_products as t ON t.id = m.product_id
      WHERE m.rank = 1
      ORDER BY t.orders_count DESC
      LIMIT ?;
    SQL
  end
end
