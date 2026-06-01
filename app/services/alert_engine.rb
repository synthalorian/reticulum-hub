# frozen_string_literal: true

# AlertEngine evaluates alert rules against live network data and
# creates Alert records when conditions are met.
#
class AlertEngine
  def initialize(rns_adapter = nil)
    @rns = rns_adapter || RnsAdapter.new
    @rns.connect unless @rns.connected?
  end

  def evaluate_all
    AlertRule.where(enabled: true).find_each do |rule|
      evaluate(rule)
    end
  end

  def evaluate(rule)
    case rule.condition
    when "peer_down"
      evaluate_peer_down(rule)
    when "link_quality"
      evaluate_link_quality(rule)
    when "interface_error"
      evaluate_interface_error(rule)
    when "bandwidth_threshold"
      evaluate_bandwidth_threshold(rule)
    end
  end

  private

  def evaluate_peer_down(rule)
    peers = @rns.peers
    peers.each do |peer_data|
      next unless peer_data[:status] == "offline" || peer_data[:status] == "down"

      create_alert(rule, :critical, "Peer #{peer_data[:name]} is offline", peer_data)
    end
  end

  def evaluate_link_quality(rule)
    peers = @rns.peers
    peers.each do |peer_data|
      quality = peer_data[:link_quality].to_f
      next if quality >= rule.threshold

      create_alert(rule, :warning, "Link quality to #{peer_data[:name]} degraded (#{(quality * 100).round(1)}%)", peer_data)
    end
  end

  def evaluate_interface_error(rule)
    interfaces = @rns.interfaces
    interfaces.each do |iface_data|
      next if iface_data[:status] == "up"

      create_alert(rule, :error, "Interface #{iface_data[:name]} is #{iface_data[:status]}", iface_data)
    end
  end

  def evaluate_bandwidth_threshold(rule)
    stats = @rns.system_stats
    total_bw = stats[:bandwidth_in].to_i + stats[:bandwidth_out].to_i
    return if total_bw < rule.threshold

    create_alert(rule, :warning, "Bandwidth threshold exceeded (#{format_bytes(total_bw)}/s)", stats)
  end

  def create_alert(rule, severity, message, details)
    # Deduplicate: don't create if an active alert for this rule+message exists
    return if Alert.exists?(alert_rule: rule, status: "active", message: message)

    alert = Alert.create!(
      alert_rule: rule,
      status: "active",
      severity: severity,
      message: message,
      details: details,
      triggered_at: Time.current
    )

    Notifiers::Dispatch.send(alert)
    alert
  end

  def format_bytes(bytes)
    return "#{bytes} B" if bytes < 1024
    return "#{(bytes / 1024.0).round(1)} KB" if bytes < 1024 * 1024
    return "#{(bytes / (1024.0 * 1024)).round(1)} MB" if bytes < 1024 * 1024 * 1024
    "#{(bytes / (1024.0 * 1024 * 1024)).round(1)} GB"
  end
end
