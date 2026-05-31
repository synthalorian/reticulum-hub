# frozen_string_literal: true

class Interface < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :interface_type, presence: true
  validates :status, inclusion: { in: %w[up down error unknown] }

  scope :active, -> { where(status: "up") }
  scope :inactive, -> { where(status: "down") }

  def status_badge_class
    case status
    when "up" then "bg-green-100 text-green-800"
    when "down" then "bg-gray-100 text-gray-800"
    when "error" then "bg-red-100 text-red-800"
    else "bg-yellow-100 text-yellow-800"
    end
  end

  def formatted_uptime
    return "—" unless uptime && uptime > 0
    hours = uptime / 3600
    minutes = (uptime % 3600) / 60
    "#{hours}h #{minutes}m"
  end

  def formatted_bandwidth
    return "—" unless bandwidth_in || bandwidth_out
    in_str = bandwidth_in ? format_bytes(bandwidth_in) : "0"
    out_str = bandwidth_out ? format_bytes(bandwidth_out) : "0"
    "↓#{in_str} ↑#{out_str}"
  end

  private

  def format_bytes(bytes)
    return "#{bytes}B" if bytes < 1024
    return "#{(bytes / 1024.0).round(1)}KB" if bytes < 1024 * 1024
    return "#{(bytes / (1024.0 * 1024)).round(1)}MB" if bytes < 1024 * 1024 * 1024
    "#{(bytes / (1024.0 * 1024 * 1024)).round(1)}GB"
  end
end
