# frozen_string_literal: true

module Notifiers
  class LxmfNotifier
    def self.notify(alert, destination_hash: nil)
      dest = destination_hash || ENV.fetch("ALERT_LXMF_DESTINATION", nil)
      return unless dest

      rns = RnsAdapter.new
      rns.connect
      subject = "[#{alert.severity.upcase}] #{alert.alert_rule&.name || "Alert"}"
      body = "Alert triggered at #{alert.triggered_at}\n\n#{alert.message}\n\nDetails: #{alert.details}"
      rns.send_lxmf(dest, subject, body)
    rescue => e
      Rails.logger.error "[LxmfNotifier] Failed to send LXMF: #{e.message}"
    end
  end
end
