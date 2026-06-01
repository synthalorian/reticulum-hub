# frozen_string_literal: true

module Notifiers
  class EmailNotifier
    def self.notify(alert)
      Rails.logger.info "[EmailNotifier] Would send email for alert: #{alert.message}"
      # TODO: Configure ActionMailer with SMTP settings
      # AlertMailer.alert_triggered(alert).deliver_later
    end
  end
end
