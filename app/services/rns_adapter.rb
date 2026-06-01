# frozen_string_literal: true

# RnsAdapter connects to the Reticulum Network Stack daemon (rnsd)
# via CLI tools (rnstatus, rnpath, etc.) and provides a Ruby interface
# for querying status, sending commands, and receiving events.
#
# When rnsd is not available, the adapter falls back to mock data
# so the dashboard remains functional for development and demo.
#
class RnsAdapter
  DEFAULT_TCP_HOST = "127.0.0.1"
  DEFAULT_TCP_PORT = 3742
  DEFAULT_SOCKET_PATH = "~/.reticulum/rnsd.sock"

  class ConnectionError < StandardError; end

  def initialize(host: nil, port: nil, socket_path: nil)
    @host = host || ENV.fetch("RNSD_HOST", DEFAULT_TCP_HOST)
    @port = port || ENV.fetch("RNSD_PORT", DEFAULT_TCP_PORT).to_i
    @socket_path = File.expand_path(socket_path || ENV.fetch("RNSD_SOCKET", DEFAULT_SOCKET_PATH))
    @connected = false
    @mutex = Mutex.new
  end

  # ------------------------------------------------------------------
  # Connection
  # ------------------------------------------------------------------

  def connected?
    @connected
  end

  def connect
    @mutex.synchronize do
      # Try CLI tools first (preferred method)
      if cli_available?
        @connected = true
        return true
      end

      # Fallback: try Unix socket
      if File.exist?(@socket_path)
        @socket = UNIXSocket.new(@socket_path)
        @connected = true
        return true
      end

      # Fallback: try TCP
      begin
        @socket = TCPSocket.new(@host, @port)
        @connected = true
        return true
      rescue => e
        Rails.logger.warn "RnsAdapter: could not connect to rnsd (#{e.message})"
        @connected = false
        return false
      end
    end
  end

  def disconnect
    @mutex.synchronize do
      @socket&.close
      @socket = nil
      @connected = false
    end
  end

  # ------------------------------------------------------------------
  # Status queries
  # ------------------------------------------------------------------

  def peers
    return mock_peers unless connected?

    if cli_available?
      parse_cli_peers
    else
      response = send_command("peers")
      parse_peers(response)
    end
  rescue ConnectionError
    mock_peers
  end

  def interfaces
    return mock_interfaces unless connected?

    if cli_available?
      parse_cli_interfaces
    else
      response = send_command("interfaces")
      parse_interfaces(response)
    end
  rescue ConnectionError
    mock_interfaces
  end

  def system_stats
    return mock_system_stats unless connected?

    if cli_available?
      parse_cli_stats
    else
      response = send_command("stats")
      parse_stats(response)
    end
  rescue ConnectionError
    mock_system_stats
  end

  def nodes
    return mock_nodes unless connected?

    if cli_available?
      parse_cli_nodes
    else
      response = send_command("nodes")
      parse_nodes(response)
    end
  rescue ConnectionError
    mock_nodes
  end

  # ------------------------------------------------------------------
  # LXMF messaging
  # ------------------------------------------------------------------

  def send_lxmf(destination_hash, subject, body, attachment: nil)
    return false unless connected?

    # Try real LXMF first, fall back to stub
    lxmf = LxmfAdapter.new
    lxmf.connect
    if lxmf.connected?
      lxmf.send_message(destination_hash, subject, body, attachment: attachment)
    else
      Rails.logger.info "RnsAdapter: LXMF send to #{destination_hash} (stub mode)"
      true
    end
  rescue ConnectionError
    false
  end

  def lxmf_inbox
    return [] unless connected?

    # LXMF inbox requires lxmf daemon
    []
  rescue ConnectionError
    []
  end

  # ------------------------------------------------------------------
  # Interface management
  # ------------------------------------------------------------------

  def enable_interface(name)
    return false unless connected?

    # Interface management via rnsd is not directly supported via CLI
    # This would require modifying the config and restarting rnsd
    Rails.logger.info "RnsAdapter: Enable interface #{name} (requires config change)"
    false
  rescue ConnectionError
    false
  end

  def disable_interface(name)
    return false unless connected?

    Rails.logger.info "RnsAdapter: Disable interface #{name} (requires config change)"
    false
  rescue ConnectionError
    false
  end

  def restart_interface(name)
    return false unless connected?

    Rails.logger.info "RnsAdapter: Restart interface #{name} (requires config change)"
    false
  rescue ConnectionError
    false
  end

  # ------------------------------------------------------------------
  # Announcements
  # ------------------------------------------------------------------

  def announce(service_name, service_type, port: nil, data: nil)
    return false unless connected?

    Rails.logger.info "RnsAdapter: Announce #{service_name} (#{service_type})"
    false
  rescue ConnectionError
    false
  end

  # ------------------------------------------------------------------
  # Private
  # ------------------------------------------------------------------

  private

  def cli_available?
    system("which rnstatus > /dev/null 2>&1")
  end

  def run_cli(cmd)
    output = `#{cmd} 2>&1`
    raise ConnectionError, "Command failed: #{cmd}" unless $?.success?
    output
  end

  def parse_cli_interfaces
    output = run_cli("rnstatus -j")
    data = JSON.parse(output)

    (data["interfaces"] || []).map do |iface|
      {
        name: iface["name"],
        interface_type: iface["type"],
        status: iface["status"] == true ? "up" : "down",
        config: {},
        bandwidth_in: iface["rxb"] || 0,
        bandwidth_out: iface["txb"] || 0,
        error_rate: 0.0,
        uptime: 0,
        last_seen: Time.current,
        metadata: {
          bitrate: iface["bitrate"],
          peers: iface["peers"],
          clients: iface["clients"],
          mode: iface["mode"]
        }
      }
    end
  rescue JSON::ParserError => e
    Rails.logger.error "RnsAdapter: JSON parse error (#{e.message})"
    mock_interfaces
  end

  def parse_cli_stats
    output = run_cli("rnstatus -j")
    data = JSON.parse(output)

    {
      cpu_percent: 0.0,
      memory_percent: 0.0,
      bandwidth_in: data["rxb"] || 0,
      bandwidth_out: data["txb"] || 0,
      uptime: 0,
      peer_count: 0,
      interface_count: (data["interfaces"] || []).size,
      metadata: {
        rxs: data["rxs"],
        txs: data["txs"],
        rss: data["rss"]
      }
    }
  rescue JSON::ParserError => e
    Rails.logger.error "RnsAdapter: JSON parse error (#{e.message})"
    mock_system_stats
  end

  def parse_cli_peers
    # rnstatus doesn't have a direct peers command, but we can get peer info from paths
    output = run_cli("rnpath -t -j 2>/dev/null || echo '[]'")
    data = JSON.parse(output)

    (data || []).map do |path|
      {
        destination_hash: path["hash"] || "<unknown>",
        name: path["name"] || "Unknown",
        last_seen: Time.current,
        link_quality: 1.0,
        hops: path["hops"] || 0,
        status: "active"
      }
    end
  rescue JSON::ParserError => e
    Rails.logger.error "RnsAdapter: JSON parse error (#{e.message})"
    mock_peers
  end

  def parse_cli_nodes
    # Nodes are discovered through announces — rnstatus -A shows announce stats
    output = run_cli("rnstatus -j")
    data = JSON.parse(output)

    # For now, return interfaces as nodes since that's what we can discover
    (data["interfaces"] || []).map do |iface|
      {
        destination_hash: iface["hash"] || "<unknown>",
        name: iface["name"] || "Unknown",
        hops: 0,
        last_seen: Time.current,
        services: [],
        metadata: {
          type: iface["type"],
          bitrate: iface["bitrate"]
        }
      }
    end
  rescue JSON::ParserError => e
    Rails.logger.error "RnsAdapter: JSON parse error (#{e.message})"
    mock_nodes
  end

  def send_command(cmd, params = {})
    raise ConnectionError, "Not connected" unless @socket

    request = { command: cmd, params: params }.to_json
    @socket.puts(request)
    response = @socket.gets
    raise ConnectionError, "No response" unless response

    JSON.parse(response)
  rescue JSON::ParserError => e
    Rails.logger.error "RnsAdapter: JSON parse error (#{e.message})"
    { "status" => "error", "message" => e.message }
  rescue Errno::EPIPE, Errno::ECONNRESET, IOError => e
    @connected = false
    raise ConnectionError, e.message
  end

  # ------------------------------------------------------------------
  # Mock data for development / when rnsd is unavailable
  # ------------------------------------------------------------------

  def mock_peers
    [
      { destination_hash: "<f0a1b2c3>", name: "Field Node Alpha", last_seen: 2.minutes.ago, link_quality: 0.92, hops: 1, status: "active" },
      { destination_hash: "<d4e5f6a7>", name: "Base Station", last_seen: 30.seconds.ago, link_quality: 0.98, hops: 0, status: "active" },
      { destination_hash: "<b8c9d0e1>", name: "Relay Node 1", last_seen: 5.minutes.ago, link_quality: 0.74, hops: 2, status: "active" },
      { destination_hash: "<f2a3b4c5>", name: "Mobile Unit 3", last_seen: 15.minutes.ago, link_quality: 0.45, hops: 3, status: "degraded" },
      { destination_hash: "<d6e7f8a9>", name: "Gateway Node", last_seen: 1.hour.ago, link_quality: 0.0, hops: 1, status: "offline" }
    ]
  end

  def mock_interfaces
    [
      { name: "AutoInterface", interface_type: "AutoInterface", status: "up", config: {}, bandwidth_in: 1_240_000, bandwidth_out: 890_000, error_rate: 0.001, uptime: 86400, last_seen: Time.current, metadata: {} },
      { name: "TCP Client", interface_type: "TCPClient", status: "up", config: { target_host: "192.168.1.100", target_port: 4242 }, bandwidth_in: 450_000, bandwidth_out: 320_000, error_rate: 0.0, uptime: 43200, last_seen: Time.current, metadata: {} },
      { name: "RNode USB", interface_type: "RNode", status: "up", config: { port: "/dev/ttyUSB0", frequency: 915000000 }, bandwidth_in: 12_000, bandwidth_out: 8_000, error_rate: 0.02, uptime: 86400, last_seen: Time.current, metadata: {} },
      { name: "LoRa Module", interface_type: "LoRa", status: "down", config: { frequency: 868000000, spreading_factor: 7 }, bandwidth_in: 0, bandwidth_out: 0, error_rate: 0.0, uptime: 0, last_seen: nil, metadata: {} }
    ]
  end

  def mock_system_stats
    {
      cpu_percent: 12.5,
      memory_percent: 34.2,
      bandwidth_in: 1_702_000,
      bandwidth_out: 1_218_000,
      uptime: 86400,
      peer_count: 4,
      interface_count: 3,
      metadata: { load_average: [0.45, 0.38, 0.42], temperature: 42.0 }
    }
  end

  def mock_nodes
    [
      { destination_hash: "<f0a1b2c3>", name: "Field Node Alpha", hops: 1, last_seen: 2.minutes.ago, services: [{ type: "lxmf", port: 8 }, { type: "nomad", port: 42 }], metadata: {} },
      { destination_hash: "<d4e5f6a7>", name: "Base Station", hops: 0, last_seen: 30.seconds.ago, services: [{ type: "lxmf", port: 8 }, { type: "fileshare", port: 99 }], metadata: {} },
      { destination_hash: "<b8c9d0e1>", name: "Relay Node 1", hops: 2, last_seen: 5.minutes.ago, services: [{ type: "lxmf", port: 8 }], metadata: {} }
    ]
  end

  def parse_peers(response)
    response["peers"] || []
  end

  def parse_interfaces(response)
    response["interfaces"] || []
  end

  def parse_stats(response)
    response["stats"] || mock_system_stats
  end

  def parse_nodes(response)
    response["nodes"] || []
  end
end