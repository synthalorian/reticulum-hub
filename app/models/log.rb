class Log < ApplicationRecord
  LEVELS = %w[debug info warn error fatal].freeze
  SOURCES = %w[rnsd system hub lxmf].freeze

  validates :source, presence: true, inclusion: { in: SOURCES }
  validates :level, presence: true, inclusion: { in: LEVELS }
  validates :message, presence: true

  scope :recent, -> { order(timestamp: :desc).limit(500) }
  scope :by_source, ->(source) { where(source: source) }
  scope :by_level, ->(level) { where(level: level) }
  scope :since, ->(time) { where("timestamp > ?", time) }
  scope :search, ->(q) { where("message LIKE ?", "%#{q}%") }

  def self.severity_color
    {
      "debug" => "text-gray-400",
      "info" => "text-cyan-400",
      "warn" => "text-yellow-400",
      "error" => "text-red-400",
      "fatal" => "text-red-500 font-bold"
    }
  end

  def self.level_badge_class
    {
      "debug" => "bg-gray-800 text-gray-400 border-gray-600",
      "info" => "bg-cyan-900/30 text-cyan-400 border-cyan-700",
      "warn" => "bg-yellow-900/30 text-yellow-400 border-yellow-700",
      "error" => "bg-red-900/30 text-red-400 border-red-700",
      "fatal" => "bg-red-900/50 text-red-400 border-red-500 font-bold"
    }
  end

  def color_class
    self.class.severity_color[level] || "text-gray-300"
  end

  def badge_class
    self.class.level_badge_class[level] || "bg-gray-800 text-gray-300"
  end
end
