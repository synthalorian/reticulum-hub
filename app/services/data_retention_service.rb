class DataRetentionService
  DEFAULT_POLICIES = {
    logs: { days: 30 },
    network_metrics: { days: 90 },
    system_stats: { days: 30 },
    messages: { days: 365 },
    alerts: { days: 180 }
  }.freeze

  def self.cleanup!(policies = DEFAULT_POLICIES)
    results = {}

    if policies[:logs]
      count = Log.where("timestamp < ?", policies[:logs][:days].days.ago).delete_all
      results[:logs] = count
    end

    if policies[:network_metrics]
      count = NetworkMetric.where("timestamp < ?", policies[:network_metrics][:days].days.ago).delete_all
      results[:network_metrics] = count
    end

    if policies[:system_stats]
      count = SystemStat.where("created_at < ?", policies[:system_stats][:days].days.ago).delete_all
      results[:system_stats] = count
    end

    if policies[:messages]
      count = Message.where("created_at < ?", policies[:messages][:days].days.ago).delete_all
      results[:messages] = count
    end

    if policies[:alerts]
      count = Alert.where("created_at < ?", policies[:alerts][:days].days.ago).where.not(status: "active").delete_all
      results[:alerts] = count
    end

    Rails.logger.info "DataRetentionService: #{results.inspect}"
    results
  end

  def self.stats
    {
      logs: Log.count,
      network_metrics: NetworkMetric.count,
      system_stats: SystemStat.count,
      messages: Message.count,
      alerts: Alert.count
    }
  end
end
