# frozen_string_literal: true

class Alert < ApplicationRecord
  belongs_to :alert_rule

  validates :status, inclusion: { in: %w[active acknowledged resolved] }
  validates :severity, inclusion: { in: %w[critical error warning info] }

  scope :active, -> { where(status: "active") }
  scope :acknowledged, -> { where(status: "acknowledged") }
  scope :resolved, -> { where(status: "resolved") }
  scope :critical, -> { where(severity: "critical") }

  def acknowledge!
    update!(status: "acknowledged", acknowledged_at: Time.current)
  end

  def resolve!
    update!(status: "resolved", resolved_at: Time.current)
  end

  def severity_color
    case severity
    when "critical" then "red"
    when "error" then "orange"
    when "warning" then "yellow"
    else "blue"
    end
  end

  def severity_badge_class
    case severity
    when "critical" then "bg-red-100 text-red-800 border-red-200"
    when "error" then "bg-orange-100 text-orange-800 border-orange-200"
    when "warning" then "bg-yellow-100 text-yellow-800 border-yellow-200"
    else "bg-blue-100 text-blue-800 border-blue-200"
    end
  end
end
