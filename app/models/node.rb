# frozen_string_literal: true

class Node < ApplicationRecord
  validates :destination_hash, presence: true, uniqueness: true

  has_many :services, dependent: :destroy

  scope :recent, -> { where("last_seen > ?", 5.minutes.ago) }
  scope :reachable, -> { where("hops > ?", 0) }

  def service_types
    services.pluck(:service_type).uniq
  end

  def formatted_hops
    hops == 0 ? "local" : "#{hops} hop#{'s' if hops != 1}"
  end
end
