module PrivatePubServer
  module PresencePublisher
    PRESENCE_CHANNEL = 'presence'

    class << self
      def publish_presence(channel, user_id, client_id)
        publish_to PRESENCE_CHANNEL, event: 'join', channel: channel, user_id: user_id, client_id: client_id
      end

      def publish_absence(channel, user_id, client_id)
        publish_to PRESENCE_CHANNEL, event: 'leave', channel: channel, user_id: user_id, client_id: client_id
      end

      def async_publish_presence(*args)
        PrivatePubServer.logger.debug "enqueue job #{args}"
        Resque.enqueue(PresencePublisherJob, :publish_presence, *args)
      end

      def async_publish_absence(*args)
        PrivatePubServer.logger.debug "enqueue job #{args}"
        Resque.enqueue(PresencePublisherJob, :publish_absence, *args)
      end

      private

      def publish_to(*args)
        PrivatePubServer.logger.info "presence publishing: #{args}"
        PrivatePub.publish_to(*args)
      end
    end
  end
end
