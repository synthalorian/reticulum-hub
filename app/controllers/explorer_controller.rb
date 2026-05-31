# frozen_string_literal: true

class ExplorerController < ApplicationController
  def index
    rns = RnsAdapter.new
    rns.connect
    @nodes = rns.nodes.map do |n|
      node = Node.find_or_initialize_by(destination_hash: n[:destination_hash])
      node.assign_attributes(n.except(:services))
      node
    end
    @network_map = NetworkMap.new(rns).graph
  end

  def show
    @node = Node.find_by(destination_hash: params[:id])
    unless @node
      rns = RnsAdapter.new
      rns.connect
      details = rns.nodes.find { |n| n[:destination_hash] == params[:id] }
      if details
        @node = Node.find_or_initialize_by(destination_hash: details[:destination_hash])
        @node.assign_attributes(details.except(:services))
      end
    end
    @services = @node&.services || []
  end
end
