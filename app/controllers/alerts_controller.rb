# frozen_string_literal: true

class AlertsController < ApplicationController
  def index
    @alerts = Alert.order(triggered_at: :desc).limit(100)
    @active_count = Alert.active.count
    @critical_count = Alert.critical.count
  end

  def show
    @alert = Alert.find(params[:id])
  end

  def acknowledge
    @alert = Alert.find(params[:id])
    @alert.acknowledge!
    redirect_to alerts_path, notice: "Alert acknowledged."
  end

  def resolve
    @alert = Alert.find(params[:id])
    @alert.resolve!
    redirect_to alerts_path, notice: "Alert resolved."
  end
end
