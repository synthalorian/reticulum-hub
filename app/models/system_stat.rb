# frozen_string_literal: true

class SystemStat < ApplicationRecord
  validates :cpu_percent, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :memory_percent, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  scope :recent, -> { where("created_at > ?", 1.hour.ago) }

  def formatted_uptime
    return "—" unless uptime && uptime > 0
    days = uptime / 86400
    hours = (uptime % 86400) / 3600
    minutes = (uptime % 3600) / 60
    parts = []
    parts << "#{days}d" if days > 0
    parts << "#{hours}h" if hours > 0
    parts << "#{minutes}m" if minutes > 0
    parts.join(" ")
  end
end
