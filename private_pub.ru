# Run with: rackup private_pub.ru -s thin -E production
require "bundler/setup"
require "yaml"
require "faye"
require "faye/redis"
require "private_pub"

Faye::WebSocket.load_adapter('thin')

PrivatePub.load_config(File.expand_path("../config/private_pub.yml", __FILE__),
                       ENV["RAILS_ENV"] || "development")

DEFAULT_REDIS_URL = "redis://127.0.0.1:63792"
engine_opts = {
  type: Faye::Redis,
  uri: ENV['REDISTOGO_URL'] || ENV['REDIS_URL'],
  namespace: 'private_pub'
}

puts "Running with #{engine_opts.inspect}"

run PrivatePub.faye_app(engine: engine_opts)
