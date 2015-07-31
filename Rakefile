require 'resque/tasks'

task :environment do
  require_relative 'lib/private_pub_server'
  run_env = ENV['SERVER_ENV'] || "development"
  PrivatePubServer.load_config(File.expand_path("../config/private_pub.yml", __FILE__), run_env)
end

task "resque:setup" => :environment

task :reset_store => :environment do
  redis_uri = ENV['REDIS_URL']  || 'redis://localhost:6379'
  redis_ns  = ENV['REDIS_NS']   || 'faye_tracking'

  FayeTracking.configure do |config|
    config.redis  = Redis::Namespace.new(redis_ns, redis: Redis.new(url: redis_uri))
  end

  FayeTracking.reset_store
end
