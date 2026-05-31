# frozen_string_literal: true

class ExplorerController < ApplicationController
  def index
    rns = RnsAdapter.new
    rns.connect
    @nodes = rns.nodes.map { |n| Node.new(n) }
    @network_map = NetworkMap.new(rns).graph
  end

  def show
    @node = Node.find_by(destination_hash: params[:id])
    unless @node
      rns = RnsAdapter.new
      rns.connect
      details = rns.nodes.find { |n| n[:destination_hash] == params[:id] }
      @node = Node.new(details) if details
    end
    @services = @node&.services || []
  end
end
