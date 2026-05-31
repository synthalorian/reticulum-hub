# frozen_string_literal: true

class AnnouncesController < ApplicationController
  def index
    rns = RnsAdapter.new
    rns.connect
    @nodes = rns.nodes.map do |n|
      node = Node.find_or_initialize_by(destination_hash: n[:destination_hash])
      node.assign_attributes(n.except(:services))
      node
    end
  end

  def create
    rns = RnsAdapter.new
    rns.connect
    if rns.announce(params[:name], params[:service_type], port: params[:port])
      redirect_to explorer_index_path, notice: "Announcement sent."
    else
      redirect_to explorer_index_path, alert: "Failed to send announcement."
    end
  end
end
