require 'spec_helper'

describe PrivatePubServer::PresencePublisher do
  before do
    ResqueSpec.reset!
  end

  it 'publishes presence' do
    expect(PrivatePub).to receive(:publish_to).with \
      '/room',
      event: 'join',
      user_id: 'user_1',
      client_id: 'client_1',
      users: ['user_1', 'admin_1']

    with_resque do
      described_class.async_publish_presence(
        channel: '/room',
        user_id: 'user_1',
        client_id: 'client_1',
        users: ['user_1', 'admin_1']
      )
    end
  end

  it 'publishes absense' do
    expect(PrivatePub).to receive(:publish_to).with \
      '/room',
      event: 'leave',
      user_id: 'user_1',
      client_id: 'client_1',
      users: ['admin_1']

    with_resque do
      described_class.async_publish_absence(
        channel: '/room',
        user_id: 'user_1',
        client_id: 'client_1',
        users: ['admin_1']
      )
    end
  end
end

