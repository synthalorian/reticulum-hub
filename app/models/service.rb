# frozen_string_literal: true

class Service < ApplicationRecord
  belongs_to :node

  validates :service_type, presence: true
  validates :name, presence: true

  scope :by_type, ->(type) { where(service_type: type) }
end
