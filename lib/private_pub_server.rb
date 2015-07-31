module PrivatePubServer
  PRESENCE_CHANNEL = 'presence'

  class << self
    def publish_presence(channel:, user_id:, client_id:)
      publish_to PRESENCE_CHANNEL, event: 'join', channel: channel, user_id: user_id, client_id: client_id
    end

    def publish_absence(channel:, user_id:, client_id:)
      publish_to PRESENCE_CHANNEL, event: 'leave', channel: channel, user_id: user_id, client_id: client_id
    end

    private

    def publish_to(*args)
      FayeTracking.logger.info "presence publishing: #{args}"
      PrivatePub.publish_to(*args)
    end
  end
end
