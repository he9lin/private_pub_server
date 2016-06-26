require "bundler/setup"
require "yaml"
require "logger"
require "faye"
require "faye/redis"
require "private_pub"

redis_url = ENV["REDIS_URL"] || "redis://127.0.0.1:6379/0"
redis_ns  = ENV["REDIS_NS"]  || "private_pub"
rack_env  = ENV["RACK_ENV"]  || "development"
logger    = Logger.new(STDOUT)

PrivatePub.load_config(File.expand_path("../config/private_pub.yml", __FILE__),
                       rack_env)

engine_opts = {
	type: Faye::Redis,
	uri: redis_url,
	namespace: redis_ns
}

logger.info "Running with #{engine_opts}"

run PrivatePub.faye_app(engine: engine_opts)
