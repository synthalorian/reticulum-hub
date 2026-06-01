# frozen_string_literal: true

module Notifiers
  class WebhookNotifier
    def self.notify(alert, url: nil)
      webhook_url = url || ENV.fetch("ALERT_WEBHOOK_URL", nil)
      return unless webhook_url

      payload = {
        severity: alert.severity,
        message: alert.message,
        status: alert.status,
        triggered_at: alert.triggered_at,
        details: alert.details
      }

      begin
        uri = URI.parse(webhook_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
        http.open_timeout = 5
        http.read_timeout = 5

        request = Net::HTTP::Post.new(uri.path, { "Content-Type" => "application/json" })
        request.body = payload.to_json

        response = http.request(request)
        Rails.logger.info "[WebhookNotifier] Sent alert to #{webhook_url}, status: #{response.code}"
      rescue => e
        Rails.logger.error "[WebhookNotifier] Failed to send webhook: #{e.message}"
      end
    end
  end
end
