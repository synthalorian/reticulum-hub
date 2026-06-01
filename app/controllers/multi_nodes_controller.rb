# frozen_string_literal: true

class MultiNodesController < ApplicationController
  def index
    @nodes = configured_nodes
  end

  def show
    @node = configured_nodes.find { |n| n[:id] == params[:id] }
    return redirect_to multi_nodes_path, alert: "Node not found" unless @node

    adapter = RnsAdapter.new(
      host: @node[:host],
      port: @node[:port],
      socket_path: @node[:socket]
    )
    adapter.connect

    @peers = adapter.peers
    @interfaces = adapter.interfaces
    @stats = adapter.system_stats
  end

  private

  def configured_nodes
    # Load from ENV or a settings file
    # Format: NODE_1_NAME=home,NODE_1_HOST=127.0.0.1,NODE_1_PORT=3742
    nodes = []
    env_nodes = ENV.fetch("RETICULUM_NODES", "")

    if env_nodes.present?
      env_nodes.split(";").each_with_index do |node_str, i|
        parts = node_str.split(",").map { |p| p.split("=", 2) }.to_h
        nodes << {
          id: "node-#{i + 1}",
          name: parts["name"] || "Node #{i + 1}",
          host: parts["host"] || "127.0.0.1",
          port: (parts["port"] || "3742").to_i,
          socket: parts["socket"] || "~/.reticulum/rnsd.sock"
        }
      end
    end

    # Default: local node
    nodes.empty? ? [local_node] : nodes
  end

  def local_node
    {
      id: "local",
      name: "Local Node",
      host: ENV.fetch("RNSD_HOST", "127.0.0.1"),
      port: ENV.fetch("RNSD_PORT", "3742").to_i,
      socket: ENV.fetch("RNSD_SOCKET", "~/.reticulum/rnsd.sock")
    }
  end
end
