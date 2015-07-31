require 'resque/tasks'

task :environment do
  require_relative 'lib/private_pub_server'

  run_env     = ENV['SERVER_ENV'] || "development"
  redis_uri   = ENV['REDIS_URL']  || 'redis://localhost:6379'
  redis_ns    = ENV['REDIS_NS']   || 'faye_tracking'
  config_file = File.expand_path("../config/private_pub.yml", __FILE__)

  PrivatePubServer.configure(
    private_pub_config_file: config_file,
    run_env:                 run_env,
    redis_uri:               redis_uri,
    redis_ns:                redis_ns
  )
end

task "resque:setup" => :environment

task :reset_store => :environment do
  FayeTracking.reset_store
end
