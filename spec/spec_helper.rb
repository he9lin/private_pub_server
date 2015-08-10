require 'rubygems'
require 'bundler'
require 'logger'

Bundler.setup(:default, :test)

$LOAD_PATH.unshift File.expand_path(File.join File.dirname(__FILE__), '..', 'lib')

require 'private_pub_server'
require 'sucker_punch/testing/inline'

logger = PrivatePubServer.logger = SuckerPunch.logger = Logger.new(STDOUT)
logger.level = Logger::INFO

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
