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
    File.open(path, "w") do |out|
      system("sqlite3", db_path, ".dump", out: out)
    end

    if File.exist?(path)
      redirect_to backups_path, notice: "Backup created: #{filename}"
    else
      redirect_to backups_path, alert: "Backup failed."
    end
  end

  def download
    path = backup_path
    if File.exist?(path)
      send_file path, filename: File.basename(path.to_s), type: "application/sql"
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
      File.open(safety, "w") do |out|
        system("sqlite3", db_path, ".dump", out: out)
      end

      # Restore
      File.open(uploaded.tempfile.path) do |input|
        system("sqlite3", db_path, in: input)
      end
      redirect_to backups_path, notice: "Database restored. Safety backup: pre_restore_#{timestamp}.sql"
    else
      redirect_to backups_path, alert: "No file uploaded."
    end
  end

  def destroy
    path = backup_path
    if File.exist?(path)
      File.delete(path)
      redirect_to backups_path, notice: "Backup deleted."
    else
      redirect_to backups_path, alert: "Backup not found."
    end
  end

  private

  # Only files directly inside backups/ are addressable; File.basename
  # strips any directory components from the user-supplied name.
  def backup_path
    Rails.root.join("backups", File.basename(params[:name].to_s))
  end
end
