class LogsController < ApplicationController
  def index
    @logs = Log.recent
    @logs = @logs.by_source(params[:source]) if params[:source].present? && Log::SOURCES.include?(params[:source])
    @logs = @logs.by_level(params[:level]) if params[:level].present? && Log::LEVELS.include?(params[:level])
    @logs = @logs.search(params[:q]) if params[:q].present?
    @logs = @logs.since(params[:since].to_i.minutes.ago) if params[:since].present?

    @sources = Log::SOURCES
    @levels = Log::LEVELS
  end

  def stream
    # SSE endpoint for live log tailing
    response.headers["Content-Type"] = "text/event-stream"
    response.headers["Cache-Control"] = "no-cache"
    response.headers["Connection"] = "keep-alive"

    sse = ActionController::Live::SSE.new(response.stream, event: "log")
    last_id = params[:last_id].to_i

    begin
      loop do
        new_logs = Log.where("id > ?", last_id).order(:id).limit(50)
        new_logs.each do |log|
          sse.write({
            id: log.id,
            source: log.source,
            level: log.level,
            message: log.message,
            timestamp: log.timestamp.iso8601,
            color_class: log.color_class,
            badge_class: log.badge_class
          })
          last_id = log.id
        end

        sleep 1
      end
    rescue ActionController::Live::ClientDisconnected
      Rails.logger.info "Log stream client disconnected"
    ensure
      sse.close
    end
  end

  def clear
    Log.where(source: params[:source] || "rnsd").delete_all
    redirect_to logs_path, notice: "Logs cleared."
  end
end
