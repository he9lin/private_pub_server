# Run with: rackup private_pub.ru -s thin -E production
require "bundler/setup"
require "yaml"
require "faye"
require "faye/redis"
require "private_pub"

Faye::WebSocket.load_adapter('thin')

PrivatePub.load_config(File.expand_path("../config/private_pub.yml", __FILE__),
                       ENV["RAILS_ENV"] || "development")

DEFAULT_REDIS_URL = "redis://127.0.0.1:6379/2"
engine_opts = {
  type: Faye::Redis,
  uri: ENV['REDISTOGO_URL'] || DEFAULT_REDIS_URL,
  namespace: 'private_pub'
}

p "Running with #{engine_opts}"

run PrivatePub.faye_app(engine: engine_opts)
