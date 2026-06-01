class MapsController < ApplicationController
  def index
    @peers = Peer.where.not(latitude: nil, longitude: nil)
    @peers_json = @peers.map do |p|
      {
        hash: p.destination_hash,
        name: p.name,
        lat: p.latitude,
        lng: p.longitude,
        location: p.location_name,
        status: p.status,
        quality: p.link_quality
      }
    end.to_json
  end
end
