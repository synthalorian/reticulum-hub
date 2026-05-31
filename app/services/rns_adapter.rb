# frozen_string_literal: true

# RnsAdapter connects to the Reticulum Network Stack daemon (rnsd)
# via TCP or Unix socket and provides a Ruby interface for querying
# status, sending commands, and receiving events.
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
      # Try Unix socket first, then TCP
      if File.exist?(@socket_path)
        @socket = UNIXSocket.new(@socket_path)
      else
        @socket = TCPSocket.new(@host, @port)
      end
      @connected = true
    end
    true
  rescue => e
    Rails.logger.warn "RnsAdapter: could not connect to rnsd (#{e.message})"
    @connected = false
    false
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

    response = send_command("peers")
    parse_peers(response)
  rescue ConnectionError
    mock_peers
  end

  def interfaces
    return mock_interfaces unless connected?

    response = send_command("interfaces")
    parse_interfaces(response)
  rescue ConnectionError
    mock_interfaces
  end

  def system_stats
    return mock_system_stats unless connected?

    response = send_command("stats")
    parse_stats(response)
  rescue ConnectionError
    mock_system_stats
  end

  def nodes
    return mock_nodes unless connected?

    response = send_command("nodes")
    parse_nodes(response)
  rescue ConnectionError
    mock_nodes
  end

  # ------------------------------------------------------------------
  # LXMF messaging
  # ------------------------------------------------------------------

  def send_lxmf(destination_hash, subject, body, attachment: nil)
    return false unless connected?

    payload = { to: destination_hash, subject: subject, body: body }
    payload[:attachment] = attachment if attachment
    response = send_command("lxmf_send", payload)
    response["status"] == "ok"
  rescue ConnectionError
    false
  end

  def lxmf_inbox
    return [] unless connected?

    response = send_command("lxmf_inbox")
    response["messages"] || []
  rescue ConnectionError
    []
  end

  # ------------------------------------------------------------------
  # Interface management
  # ------------------------------------------------------------------

  def enable_interface(name)
    return false unless connected?

    response = send_command("interface_enable", { name: name })
    response["status"] == "ok"
  rescue ConnectionError
    false
  end

  def disable_interface(name)
    return false unless connected?

    response = send_command("interface_disable", { name: name })
    response["status"] == "ok"
  rescue ConnectionError
    false
  end

  def restart_interface(name)
    return false unless connected?

    response = send_command("interface_restart", { name: name })
    response["status"] == "ok"
  rescue ConnectionError
    false
  end

  # ------------------------------------------------------------------
  # Announcements
  # ------------------------------------------------------------------

  def announce(service_name, service_type, port: nil, data: nil)
    return false unless connected?

    payload = { name: service_name, type: service_type }
    payload[:port] = port if port
    payload[:data] = data if data
    response = send_command("announce", payload)
    response["status"] == "ok"
  rescue ConnectionError
    false
  end

  # ------------------------------------------------------------------
  # Private
  # ------------------------------------------------------------------

  private

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
