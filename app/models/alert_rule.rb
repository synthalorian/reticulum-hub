# frozen_string_literal: true

class AlertRule < ApplicationRecord
  validates :name, presence: true
  validates :condition, inclusion: { in: %w[peer_down link_quality interface_error bandwidth_threshold] }
  validates :threshold, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :enabled, -> { where(enabled: true) }

  has_many :alerts, dependent: :destroy
end
