# frozen_string_literal: true

class NetworkChannel < ApplicationCable::Channel
  def subscribed
    stream_from "network_updates"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def self.broadcast_update(data)
    ActionCable.server.broadcast("network_updates", data)
  end
end
