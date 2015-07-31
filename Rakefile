require 'resque/tasks'

task :environment do
  require_relative 'lib/private_pub_server'
  run_env = ENV['SERVER_ENV'] || "development"
  PrivatePubServer.load_config(File.expand_path("../config/private_pub.yml", __FILE__), run_env)
end

task "resque:setup" => :environment
