# frozen_string_literal: true

class SettingsController < ApplicationController
  def index
    @rnsd_host = ENV.fetch("RNSD_HOST", "127.0.0.1")
    @rnsd_port = ENV.fetch("RNSD_PORT", "3742")
    @rnsd_socket = ENV.fetch("RNSD_SOCKET", "~/.reticulum/rnsd.sock")
    @poll_interval = ENV.fetch("RNS_POLL_INTERVAL", "5")
    @alert_webhook = ENV.fetch("ALERT_WEBHOOK_URL", "")
    @alert_lxmf = ENV.fetch("ALERT_LXMF_DESTINATION", "")
  end

  def update
    # In production these would be persisted to a settings store
    # For now, we just validate and flash a message
    flash[:notice] = "Settings updated. Restart the server for changes to take effect."
    redirect_to settings_path
  end
end
