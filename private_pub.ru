# Run with: rackup private_pub.ru -s thin -E production
require "bundler/setup"
require "yaml"
require "faye"
require "faye/redis"
require "redis"
require "private_pub"
require "faye_tracking"
require 'erb'
require_relative 'lib/private_pub_server'

redis_uri = ENV['REDIS_URL']  || 'redis://localhost:6379'
redis_ns  = ENV['REDIS_NS']   || 'faye_tracking'
run_env   = ENV['SERVER_ENV'] || "development"
logger    = Logger.new('log/faye_tracking.log')

# Configurations
Faye::WebSocket.load_adapter('thin')

PrivatePub.load_config(File.expand_path("../config/private_pub.yml", __FILE__), run_env)

FayeTracking.configure do |config|
  config.redis  = Redis::Namespace.new(redis_ns, redis: Redis.new(url: redis_uri))
  config.logger = logger
  config.on_subscribe do |client_id, user_id, channel|
    PrivatePubServer.publish_presence(channel: channel, user_id: user_id, client_id: client_id)
  end
end

engine_opts = {
  type: Faye::Redis,
  uri: redis_uri,
  namespace: 'private_pub'
}

extensions = [PrivatePub::FayeExtension.new, FayeTracking.faye_extension]
bayeux = PrivatePub.faye_app(engine: engine_opts, extensions: extensions)

# More robust way to detect unsubscribe event. see: http://faye.jcoglan.com/ruby/monitoring.html
bayeux.on(:unsubscribe) do |client_id, channel|
  FayeTracking.tracker.remove(channel, client_id)
  logger.debug "removed entry for client_id: #{client_id} and channel: #{channel}"

  PrivatePubServer.publish_absence(channel: channel, user_id: user_id, client_id: client_id)
end

logger.info "running private_pub in #{run_env} with config: #{PrivatePub.config}"
run bayeux
