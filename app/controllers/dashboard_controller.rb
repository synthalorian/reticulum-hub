# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @rns = RnsAdapter.new
    @rns.connect

    @peers = @rns.peers
    @interfaces = @rns.interfaces
    @stats = @rns.system_stats
    @nodes = @rns.nodes

    @active_peer_count = @peers.count { |p| p[:status] == "active" }
    @degraded_peer_count = @peers.count { |p| p[:status] == "degraded" }
    @offline_peer_count = @peers.count { |p| p[:status] == "offline" }
    @active_interface_count = @interfaces.count { |i| i[:status] == "up" }
    @alert_count = Alert.active.count
  end
end
