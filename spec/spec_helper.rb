require 'rubygems'
require 'bundler'
require 'logger'

Bundler.setup(:default, :test)

$LOAD_PATH.unshift File.expand_path(File.join File.dirname(__FILE__), '..', 'lib')

require 'resque_spec'
require 'private_pub_server'

logger = PrivatePubServer.logger = Logger.new(STDOUT)
logger.level = Logger::INFO

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
