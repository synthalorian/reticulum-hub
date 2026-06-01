# frozen_string_literal: true

module Notifiers
  class Dispatch
    def self.send(alert)
      channels = alert.alert_rule&.notification_channels || []

      channels.each do |channel|
        case channel
        when "email"
          EmailNotifier.notify(alert)
        when "webhook"
          WebhookNotifier.notify(alert)
        when "lxmf"
          LxmfNotifier.notify(alert)
        end
      end
    end
  end
end
