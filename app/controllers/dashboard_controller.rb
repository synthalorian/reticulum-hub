# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @rns = RnsAdapter.new
    @rns.connect

    @peers = @rns.peers.map { |p| Peer.new(p) }
    @interfaces = @rns.interfaces.map { |i| Interface.new(i) }
    @stats = @rns.system_stats
    @nodes = @rns.nodes.map { |n| Node.new(n) }

    @active_peer_count = @peers.count { |p| p.status == "active" }
    @degraded_peer_count = @peers.count { |p| p.status == "degraded" }
    @offline_peer_count = @peers.count { |p| p.status == "offline" }
    @active_interface_count = @interfaces.count { |i| i.status == "up" }
    @alert_count = Alert.active.count
  end
end
