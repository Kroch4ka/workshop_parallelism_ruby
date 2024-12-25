require 'net/http'
require 'uri'
require 'json'

namespace :orders do
  desc "Process orders with an HTTP request"
  task to_be_optimized: :environment do
    require 'benchmark'

    Order.destroy_all
    # Оптимизировать тут
    Parallel.map(Array.new(200)) do
      { product_id: rand(1..100), quantity: rand(1..10), current_status: :pending }
    end.tap { Order.insert_all(_1) }

    time = Benchmark.realtime do
      puts Order.pending.count
      # Оптимизировать тут
      Async do
        Order.pending.find_in_batches(batch_size: 50) do |batch|
          Async { process_batch_with_http(batch) }
        end
      end
    end

    puts "Processed orders in #{time.round(2)} seconds with HTTP request"
  end

  def process_batch_with_http(batch)
    batch.each do |order|
      Async do
        # Оптимизировать тут
        response = send_to_external_service
        if response.code.to_i == 200
          order.process!
          puts "Successfully processed Order ##{order.id}"
        else
          raise "Failed to process Order ##{order.id}: #{response.body}"
        end
      rescue StandardError => e
        Rails.logger.error("Error processing Order ##{order.id}: #{e.message}")
      end
    end
  end

  def send_to_external_service
    uri = URI.parse("https://yandex.ru")
    sleep 0.1
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'

    request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
    http.request(request)
  end
end

# Processed orders in 20.1 seconds with HTTP request (перед оптимизацией)
# Processed orders in 0.11 seconds with HTTP request (async при io bound)
# Processed orders in 0.2 seconds with HTTP request (thread при io bound)
# Processed orders in 0.24 seconds with HTTP request (parallel (для параллельного запуска обработки каждого заказа в батче) + async (для обработки каждого заказа) при io bound)
