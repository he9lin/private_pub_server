# Run with: rackup private_pub.ru -s thin -E production
require "bundler/setup"
require_relative 'lib/private_pub_server'

run_env     = ENV['SERVER_ENV'] || "development"
redis_uri   = ENV['REDIS_URL']  || 'redis://localhost:6379'
redis_ns    = ENV['REDIS_NS']   || 'faye_tracking'
config_file = File.expand_path("../config/private_pub.yml", __FILE__)
logger      = Logger.new('log/faye_tracking.log')

SuckerPunch.logger = Logger.new('log/sucker_punch.log')

# Configurations
PrivatePubServer.configure(
  private_pub_config_file: config_file,
  run_env:                 run_env,
  redis_uri:               redis_uri,
  redis_ns:                redis_ns,
  logger:                  logger
)

# Server setup
app = PrivatePubServer.app
logger.info "running private_pub in #{run_env} with config: #{PrivatePub.config}"
run app
