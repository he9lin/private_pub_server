module PrivatePubServer
  module PresencePublisher
    class << self
      def publish_presence(channel:, user_id:, client_id:, users:)
        publish_to channel,
          event: 'join',
          user_id: user_id,
          client_id: client_id,
          users: users
      end

      def publish_absence(channel:, user_id:, client_id:, users:)
        publish_to channel,
          event: 'leave',
          user_id: user_id,
          client_id: client_id,
          users: users
      end

      def async_publish_presence(*args)
        logger.debug "enqueue job #{args}"
        PresencePublisherJob.new.async.perform(:publish_presence, *args)
      end

      def async_publish_absence(*args)
        logger.debug "enqueue job #{args}"
        PresencePublisherJob.new.async.perform(:publish_absence, *args)
      end

      private

      def publish_to(*args)
        logger.debug "presence publishing: #{args}"
        PrivatePub.publish_to(*args)
      end

      def logger
        PrivatePubServer.logger
      end
    end
  end
end
