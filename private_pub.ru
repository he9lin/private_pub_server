# Run with: rackup private_pub.ru -s thin -E production
require "bundler/setup"
require "yaml"
require "faye"
require "faye/redis"
require "redis"
require "private_pub"
require "faye_tracking"

Faye::WebSocket.load_adapter('thin')

PrivatePub.load_config(File.expand_path("../config/private_pub.yml", __FILE__),
  ENV["RAILS_ENV"] || "development")

redis_uri = ENV['REDISTOGO_URL'] || 'redis://localhost:6379'

FayeTracking.configure do |config|
  config.redis = Redis::Namespace.new(:yell_faye_tracking, redis: Redis.new(url: redis_uri))
  config.logger = Logger.new('log/faye_tracking.log')
end

engine_opts = {
  type: Faye::Redis,
  uri: redis_uri,
  namespace: 'private_pub'
}

extensions = [PrivatePub::FayeExtension.new, FayeTracking.faye_extension]
run PrivatePub.faye_app(engine: engine_opts, extensions: extensions)
