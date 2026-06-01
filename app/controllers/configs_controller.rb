# frozen_string_literal: true

class ConfigsController < ApplicationController
  def index
    @config = load_rns_config
  end

  def export
    config = load_rns_config
    send_data config.to_json, filename: "reticulum-config-#{Time.current.to_i}.json", type: "application/json"
  end

  def import
    if params[:file].present?
      begin
        imported = JSON.parse(params[:file].read)
        # Validate it's a valid Reticulum config structure
        if valid_config?(imported)
          flash[:notice] = "Config validated successfully. Apply manually to ~/.reticulum/config"
        else
          flash[:alert] = "Invalid Reticulum config structure"
        end
      rescue JSON::ParserError => e
        flash[:alert] = "Invalid JSON: #{e.message}"
      end
    else
      flash[:alert] = "No file uploaded"
    end
    redirect_to configs_path
  end

  private

  def load_rns_config
    path = File.expand_path("~/.reticulum/config")
    return {} unless File.exist?(path)

    # Parse INI-style config to hash
    result = { "reticulum" => {}, "interfaces" => {} }
    current_section = nil
    current_subsection = nil

    File.readlines(path).each do |line|
      line = line.strip
      next if line.empty? || line.start_with?("#")

      if line.match?(/^\[.+\]$/)
        section = line[1..-2]
        if section.start_with?("[")
          # Subsection like [[Default Interface]]
          current_subsection = section[2..-3]
          current_section = "interfaces"
          result["interfaces"][current_subsection] ||= {}
        else
          current_section = section.downcase
          current_subsection = nil
          result[current_section] ||= {}
        end
      elsif line.include?("=")
        key, value = line.split("=", 2).map(&:strip)
        if current_subsection
          result["interfaces"][current_subsection][key] = value
        elsif current_section
          result[current_section][key] = value
        end
      end
    end

    result
  end

  def valid_config?(config)
    config.is_a?(Hash) && (config.key?("reticulum") || config.key?("interfaces"))
  end
end
