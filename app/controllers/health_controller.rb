class HealthController < ApplicationController
  def index
    @checks = HealthCheckService.run_all
    @overall = HealthCheckService.overall_status(@checks)
    @uptime = `cat /proc/uptime`.split.first.to_i rescue 0
  end

  def check
    checks = HealthCheckService.run_all
    overall = HealthCheckService.overall_status(checks)
    status_code = overall == "ok" ? 200 : overall == "warning" ? 200 : 503
    render json: { status: overall, checks: checks }, status: status_code
  end
end
