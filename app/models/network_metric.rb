class NetworkMetric < ApplicationRecord
  METRIC_TYPES = %w[rtt throughput packet_loss path_quality cpu memory].freeze

  validates :metric_type, presence: true, inclusion: { in: METRIC_TYPES }
  validates :value, presence: true, numericality: true

  scope :by_type, ->(type) { where(metric_type: type) }
  scope :for_peer, ->(hash) { where(peer_hash: hash) }
  scope :for_interface, ->(name) { where(interface_name: name) }
  scope :recent, ->(hours = 24) { where("timestamp > ?", hours.hours.ago) }
  scope :hourly_average, -> {
    select("strftime('%Y-%m-%d %H:00:00', timestamp) as hour, metric_type, AVG(value) as avg_value, COUNT(*) as count")
      .group("hour, metric_type")
      .order("hour DESC")
  }

  def self.timeseries(metric_type, hours: 24, peer_hash: nil, interface_name: nil)
    scope = by_type(metric_type).recent(hours)
    scope = scope.for_peer(peer_hash) if peer_hash
    scope = scope.for_interface(interface_name) if interface_name
    scope.order(:timestamp).pluck(:timestamp, :value)
  end

  def self.latest_for_peer(peer_hash)
    METRIC_TYPES.index_with do |type|
      by_type(type).for_peer(peer_hash).order(timestamp: :desc).first
    end
  end
end
