class BackupsController < ApplicationController
  def index
    @backups = Dir.glob(Rails.root.join("backups", "*.sql")).sort.reverse.map do |path|
      {
        name: File.basename(path),
        size: File.size(path),
        created: File.mtime(path),
        path: path
      }
    end
  end

  def create
    timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
    filename = "reticulum_hub_#{timestamp}.sql"
    backup_dir = Rails.root.join("backups")
    FileUtils.mkdir_p(backup_dir)
    path = backup_dir.join(filename)

    db_path = Rails.configuration.database_configuration[Rails.env]["database"]
    system("sqlite3 #{db_path} .dump > #{path}")

    if File.exist?(path)
      redirect_to backups_path, notice: "Backup created: #{filename}"
    else
      redirect_to backups_path, alert: "Backup failed."
    end
  end

  def download
    path = Rails.root.join("backups", params[:name])
    if File.exist?(path)
      send_file path, filename: params[:name], type: "application/sql"
    else
      redirect_to backups_path, alert: "Backup not found."
    end
  end

  def restore
    uploaded = params[:backup_file]
    if uploaded
      db_path = Rails.configuration.database_configuration[Rails.env]["database"]
      # Backup current first
      timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
      safety = Rails.root.join("backups", "pre_restore_#{timestamp}.sql")
      system("sqlite3 #{db_path} .dump > #{safety}")

      # Restore
      system("sqlite3 #{db_path} < #{uploaded.tempfile.path}")
      redirect_to backups_path, notice: "Database restored. Safety backup: pre_restore_#{timestamp}.sql"
    else
      redirect_to backups_path, alert: "No file uploaded."
    end
  end

  def destroy
    path = Rails.root.join("backups", params[:name])
    if File.exist?(path)
      File.delete(path)
      redirect_to backups_path, notice: "Backup deleted."
    else
      redirect_to backups_path, alert: "Backup not found."
    end
  end
end
