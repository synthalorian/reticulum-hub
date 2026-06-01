class RetentionController < ApplicationController
  def index
    @stats = DataRetentionService.stats
    @policies = DataRetentionService::DEFAULT_POLICIES
    @last_cleanup = Log.order(:created_at).first&.created_at
  end

  def cleanup
    results = DataRetentionService.cleanup!
    total = results.values.sum
    redirect_to retention_index_path, notice: "Cleanup complete. #{total} records removed."
  end
end
