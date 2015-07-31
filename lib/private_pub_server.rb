require "yaml"
require 'erb'
require "faye"
require "faye/redis"
require "redis"
require "private_pub"
require 'resque'
require "faye_tracking"

module PrivatePubServer
  def self.load_config(config, env)
    PrivatePub.load_config(config, env)
  end

  def self.logger
    FayeTracking.logger
  end

  def self.publish_presence(*args)
    PresencePublisher.async_publish_presence(*args)
  end

  def self.publish_absence(*args)
    PresencePublisher.async_publish_absence(*args)
  end
end

require_relative 'private_pub_server/presence_publisher'
require_relative 'private_pub_server/presence_publisher_job'
