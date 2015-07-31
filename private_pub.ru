# Run with: rackup private_pub.ru -s thin -E production
require "bundler/setup"
require_relative 'lib/private_pub_server'

redis_uri = ENV['REDIS_URL']  || 'redis://localhost:6379'
redis_ns  = ENV['REDIS_NS']   || 'faye_tracking'
run_env   = ENV['SERVER_ENV'] || "development"
logger    = Logger.new('log/faye_tracking.log')

# Configurations
Faye::WebSocket.load_adapter('thin')

PrivatePubServer.load_config(File.expand_path("../config/private_pub.yml", __FILE__), run_env)

FayeTracking.configure do |config|
  config.redis  = Redis::Namespace.new(redis_ns, redis: Redis.new(url: redis_uri))
  config.logger = logger
  config.on_subscribe do |client_id, user_id, channel|
    logger.debug "execute on_subscribe block #{client_id}"
    PrivatePubServer.publish_presence(channel, user_id, client_id)
  end
end

engine_opts = {
  type: Faye::Redis,
  uri: redis_uri,
  namespace: 'private_pub'
}

extensions = [PrivatePub::FayeExtension.new, FayeTracking.faye_extension]
bayeux = PrivatePub.faye_app(engine: engine_opts, extensions: extensions)

# More robust way to detect unsubscribe event. see: http://faye.jcoglan.com/ruby/monitoring.html
bayeux.on(:unsubscribe) do |client_id, channel|
  user_id = FayeTracking.user_with_client_id(client_id)

  FayeTracking.tracker.remove(channel, client_id)
  logger.debug "removed client_id: #{client_id} from channel: #{channel}"

  # takes care of cases when multiple client_ids for same user_id on same channel
  user_still_in_channel = FayeTracking.user_in_channel?(user_id, channel)

  if user_id
    if user_still_in_channel
      logger.debug "user #{user_id} still in channel #{channel}" if user_still_in_channel
    else
      PrivatePubServer.publish_absence(channel, user_id, client_id)
    end
  else
    logger.error "no matching user for client_id #{client_id}"
  end
end

logger.info "running private_pub in #{run_env} with config: #{PrivatePub.config}"
run bayeux
