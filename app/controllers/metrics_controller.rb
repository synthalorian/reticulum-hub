class MetricsController < ApplicationController
  def index
    @hours = (params[:hours] || 24).to_i
    @metric_types = NetworkMetric::METRIC_TYPES

    @rtt_data = NetworkMetric.timeseries("rtt", hours: @hours)
    @throughput_data = NetworkMetric.timeseries("throughput", hours: @hours)
    @path_quality_data = NetworkMetric.timeseries("path_quality", hours: @hours)
    @packet_loss_data = NetworkMetric.timeseries("packet_loss", hours: @hours)

    @peer_hashes = NetworkMetric.where.not(peer_hash: nil).distinct.pluck(:peer_hash)
    @interface_names = NetworkMetric.where.not(interface_name: nil).distinct.pluck(:interface_name)
  end

  def peer
    @peer_hash = params[:hash]
    @hours = (params[:hours] || 24).to_i
    @metrics = NetworkMetric.latest_for_peer(@peer_hash)
    @rtt_history = NetworkMetric.timeseries("rtt", hours: @hours, peer_hash: @peer_hash)
    @quality_history = NetworkMetric.timeseries("path_quality", hours: @hours, peer_hash: @peer_hash)
  end

  def interface
    @interface_name = params[:name]
    @hours = (params[:hours] || 24).to_i
    @throughput_history = NetworkMetric.timeseries("throughput", hours: @hours, interface_name: @interface_name)
    @packet_loss_history = NetworkMetric.timeseries("packet_loss", hours: @hours, interface_name: @interface_name)
  end
end
