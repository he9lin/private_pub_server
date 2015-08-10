module PrivatePubServer
  class PresencePublisherJob
    include SuckerPunch::Job

    def perform(presence_or_absence, opts)
      PrivatePubServer.logger.debug "perform presence publisher job"
      PresencePublisher.public_send(presence_or_absence, opts.symbolize_keys)
    end
  end
end
