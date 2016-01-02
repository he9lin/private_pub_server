# Run with: rackup private_pub.ru -s thin -E production
require "bundler/setup"
require "yaml"
require "faye"
require "faye/redis"
require "redis"
require "private_pub"
require "erb"
require "logger"

redis_uri = ENV['REDIS_URL']  || 'redis://localhost:6379'
redis_ns  = ENV['REDIS_NS']   || 'private_pub'
run_env   = ENV['SERVER_ENV'] || "development"
logger    = Logger.new(STDOUT)

Faye::WebSocket.load_adapter('thin')

PrivatePub.load_config(File.expand_path("../config/private_pub.yml", __FILE__), run_env)

engine_opts = {
  type:      Faye::Redis,
  uri:       redis_uri,
  namespace: redis_ns
}

extensions = [PrivatePub::FayeExtension.new]
bayeux = PrivatePub.faye_app(engine: engine_opts, extensions: extensions)

logger.info "running private_pub in #{run_env} with config: #{PrivatePub.config}"
run bayeux

