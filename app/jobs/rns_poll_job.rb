# frozen_string_literal: true

class RnsPollJob < ApplicationJob
  queue_as :default

  def perform
    rns = RnsAdapter.new
    rns.connect

    # Sync peers to database
    rns.peers.each do |peer_data|
      Peer.find_or_initialize_by(destination_hash: peer_data[:destination_hash]).tap do |peer|
        peer.assign_attributes(peer_data)
        peer.save!
      end
    end

    # Sync interfaces to database
    rns.interfaces.each do |iface_data|
      Interface.find_or_initialize_by(name: iface_data[:name]).tap do |iface|
        iface.assign_attributes(iface_data)
        iface.save!
      end
    end

    # Record system stats
    stats = rns.system_stats
    SystemStat.create!(stats)

    # Evaluate alert rules
    AlertEngine.new(rns).evaluate_all

    # Broadcast updates via Action Cable
    NetworkChannel.broadcast_update({
      type: "network_update",
      peers: rns.peers,
      interfaces: rns.interfaces,
      stats: stats,
      timestamp: Time.current.iso8601
    })
  rescue => e
    Rails.logger.error "RnsPollJob failed: #{e.message}"
    Rails.logger.error e.backtrace.first(5).join("\n")
  end
end
