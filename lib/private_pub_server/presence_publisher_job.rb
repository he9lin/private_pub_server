module PrivatePubServer
  class PresencePublisherJob
    @queue = :presence_publish

    def self.perform(presence_or_absence, channel, user_id, client_id)
      PrivatePubServer.logger.debug "perform presence publisher job"
      PresencePublisher.public_send(presence_or_absence,
        channel, user_id, client_id
      )
    end
  end
end
