# frozen_string_literal: true

class Message < ApplicationRecord
  validates :sender_hash, presence: true
  validates :recipient_hash, presence: true
  validates :direction, inclusion: { in: %w[inbound outbound] }

  scope :inbound, -> { where(direction: "inbound") }
  scope :outbound, -> { where(direction: "outbound") }
  scope :unread, -> { where(read: false) }
  scope :recent, -> { where("sent_at > ?", 24.hours.ago) }

  def conversation_key
    [ sender_hash, recipient_hash ].sort.join(":")
  end

  def status_icon
    return "✓✓" if read
    return "✓" if delivered
    "○"
  end

  def truncated_body(length: 100)
    return "" unless body
    body.length > length ? "#{body[0...length]}..." : body
  end
end
