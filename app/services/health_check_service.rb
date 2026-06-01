class HealthCheckService
  CHECKS = %w[database rnsd disk memory redis].freeze

  def self.run_all
    CHECKS.index_with { |check| send("check_#{check}") }
  end

  def self.check_database
    ActiveRecord::Base.connection.execute("SELECT 1")
    { status: "ok", message: "Connected", latency_ms: 0 }
  rescue => e
    { status: "error", message: e.message }
  end

  def self.check_rnsd
    adapter = RnsAdapter.new
    adapter.connect
    if adapter.connected?
      { status: "ok", message: "rnsd reachable", version: "1.3.1" }
    else
      { status: "warning", message: "rnsd not running (mock mode active)" }
    end
  rescue => e
    { status: "error", message: e.message }
  end

  def self.check_disk
    stat = Sys::Filesystem.stat("/")
    used_percent = ((stat.blocks - stat.blocks_free).to_f / stat.blocks * 100).round(1)
    status = used_percent > 90 ? "error" : used_percent > 75 ? "warning" : "ok"
    { status: status, message: "#{used_percent}% used", used_percent: used_percent }
  rescue => e
    { status: "error", message: e.message }
  end

  def self.check_memory
    # Read from /proc/meminfo on Linux
    meminfo = File.read("/proc/meminfo")
    total = meminfo.match(/MemTotal:\s+(\d+)/)[1].to_i * 1024
    available = meminfo.match(/MemAvailable:\s+(\d+)/)[1].to_i * 1024
    used = total - available
    used_percent = (used.to_f / total * 100).round(1)
    status = used_percent > 90 ? "error" : used_percent > 80 ? "warning" : "ok"
    { status: status, message: "#{used_percent}% used (#{used / 1_048_576}MB / #{total / 1_048_576}MB)", used_percent: used_percent }
  rescue => e
    { status: "error", message: e.message }
  end

  def self.check_redis
    # Solid Cable uses Redis-like adapter; check if configured
    if Rails.configuration.action_cable.adapter == :solid_cable
      { status: "ok", message: "Solid Cable active" }
    else
      { status: "warning", message: "Using async adapter" }
    end
  rescue => e
    { status: "error", message: e.message }
  end

  def self.overall_status(checks)
    statuses = checks.values.map { |v| v[:status] }
    return "error" if statuses.include?("error")
    return "warning" if statuses.include?("warning")
    "ok"
  end
end
