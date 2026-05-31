# frozen_string_literal: true

class Peer < ApplicationRecord
  validates :destination_hash, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[active degraded offline unknown] }

  scope :active, -> { where(status: "active") }
  scope :degraded, -> { where(status: "degraded") }
  scope :offline, -> { where(status: "offline") }
  scope :recent, -> { where("last_seen > ?", 5.minutes.ago) }

  def quality_color
    return "gray" if link_quality.nil?
    return "green" if link_quality >= 0.8
    return "yellow" if link_quality >= 0.5
    "red"
  end

  def quality_badge_class
    case quality_color
    when "green" then "bg-green-100 text-green-800"
    when "yellow" then "bg-yellow-100 text-yellow-800"
    when "red" then "bg-red-100 text-red-800"
    else "bg-gray-100 text-gray-800"
    end
  end

  def formatted_last_seen
    return "never" unless last_seen
    time_ago = Time.current - last_seen
    return "just now" if time_ago < 60
    return "#{time_ago.to_i / 60}m ago" if time_ago < 3600
    return "#{time_ago.to_i / 3600}h ago" if time_ago < 86400
    "#{time_ago.to_i / 86400}d ago"
  end
end
