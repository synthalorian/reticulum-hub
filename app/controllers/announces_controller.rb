# frozen_string_literal: true

class AnnouncesController < ApplicationController
  def index
    rns = RnsAdapter.new
    rns.connect
    @nodes = rns.nodes.map { |n| Node.new(n) }
  end

  def create
    rns = RnsAdapter.new
    rns.connect
    if rns.announce(params[:name], params[:service_type], port: params[:port])
      redirect_to explorer_path, notice: "Announcement sent."
    else
      redirect_to explorer_path, alert: "Failed to send announcement."
    end
  end
end
