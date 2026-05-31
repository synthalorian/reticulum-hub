# frozen_string_literal: true

module Api
  class StatusController < ApplicationController
    def index
      rns = RnsAdapter.new
      rns.connect
      render json: {
        connected: rns.connected?,
        peers: rns.peers,
        interfaces: rns.interfaces,
        stats: rns.system_stats
      }
    end

    def peers
      rns = RnsAdapter.new
      rns.connect
      render json: { peers: rns.peers }
    end

    def interfaces
      rns = RnsAdapter.new
      rns.connect
      render json: { interfaces: rns.interfaces }
    end

    def stats
      rns = RnsAdapter.new
      rns.connect
      render json: { stats: rns.system_stats }
    end
  end
end
