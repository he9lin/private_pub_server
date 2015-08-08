module PrivatePubServer
  class PresencePublisherJob
    @queue = :presence_publish

    def self.perform(presence_or_absence, opts)
      PrivatePubServer.logger.debug "perform presence publisher job"
      PresencePublisher.public_send(presence_or_absence, opts.symbolize_keys)
    end
  end
end
