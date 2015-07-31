require "yaml"
require 'erb'
require 'logger'
require "faye"
require "faye/redis"
require "redis"
require "private_pub"
require 'resque'
require "faye_tracking"

module PrivatePubServer
  class << self
    attr_accessor :logger
    attr_reader :configured, :redis_uri

    def configure(private_pub_config_file:, run_env:, redis_uri:, redis_ns:, logger: Logger.new(STDOUT))
      PrivatePub.load_config(private_pub_config_file, run_env)
      FayeTracking.configure do |config|
        config.redis  = Redis::Namespace.new(redis_ns, redis: Redis.new(url: redis_uri))
        config.logger = logger
        config.on_subscribe do |client_id, user_id, channel|
          logger.debug "execute on_subscribe block #{client_id}"
          PrivatePubServer::PresencePublisher.async_publish_presence(channel, user_id, client_id)
        end
      end

      @logger = logger
      @redis_uri = redis_uri
      @configured = true
    end

    def app
      raise 'please run PrivatePubServer.configure first' unless configured

      @app ||= begin
        Faye::WebSocket.load_adapter('thin')

        engine_opts = {
          type: Faye::Redis,
          uri: redis_uri,
          namespace: 'private_pub'
        }
        extensions = [PrivatePub::FayeExtension.new, FayeTracking.faye_extension]

        app = PrivatePub.faye_app(engine: engine_opts, extensions: extensions)

        # More robust way to detect unsubscribe event.
        # http://faye.jcoglan.com/ruby/monitoring.html
        app.on(:unsubscribe) do |client_id, channel|
          user_id = FayeTracking.user_with_client_id(client_id)

          FayeTracking.remove_from_channel(channel, client_id)
          logger.debug "removed client_id: #{client_id} from channel: #{channel}"

          PrivatePubServer.publish_absence(channel, user_id, client_id)
        end

        app
      end
    end

    def publish_absence(channel, user_id, client_id)
      # takes care of cases when multiple client_ids for same user_id on same channel
      user_still_in_channel = FayeTracking.user_in_channel?(user_id, channel)

      if user_id
        if user_still_in_channel
          logger.debug "user #{user_id} still in channel #{channel}" if user_still_in_channel
        else
          PresencePublisher.async_publish_absence(channel, user_id, client_id)
        end
      else
        logger.error "no matching user for client_id #{client_id}"
      end
    end
  end
end

require_relative 'private_pub_server/presence_publisher'
require_relative 'private_pub_server/presence_publisher_job'
