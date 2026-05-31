import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

// NetworkStatusController handles real-time updates from the RNS daemon
// via Action Cable WebSocket connection.
//
export default class extends Controller {
  static targets = ["activePeers", "degradedPeers", "offlinePeers", "alertCount", "peersTable", "interfacesGrid", "connectionStatus", "connectionText"]

  connect() {
    this.subscription = createConsumer().subscriptions.create("NetworkChannel", {
      received: this.handleUpdate.bind(this)
    })

    // Fallback polling every 5 seconds if WebSocket isn't available
    this.pollInterval = setInterval(() => this.pollStatus(), 5000)
    this.pollStatus()
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
    if (this.pollInterval) {
      clearInterval(this.pollInterval)
    }
  }

  handleUpdate(data) {
    if (data.type === "network_update") {
      this.updateStats(data)
      this.updatePeers(data.peers)
      this.updateInterfaces(data.interfaces)
      this.updateConnectionStatus(true)
    }
  }

  async pollStatus() {
    try {
      const response = await fetch("/api/status")
      if (!response.ok) throw new Error("HTTP " + response.status)
      const data = await response.json()
      this.updateStats(data)
      this.updatePeers(data.peers)
      this.updateInterfaces(data.interfaces)
      this.updateConnectionStatus(data.connected)
    } catch (e) {
      this.updateConnectionStatus(false)
    }
  }

  updateStats(data) {
    const peers = data.peers || []
    const active = peers.filter(p => p.status === "active" || p.status === "up").length
    const degraded = peers.filter(p => p.status === "degraded").length
    const offline = peers.filter(p => p.status === "offline" || p.status === "down").length

    if (this.hasActivePeersTarget) this.activePeersTarget.textContent = active
    if (this.hasDegradedPeersTarget) this.degradedPeersTarget.textContent = degraded
    if (this.hasOfflinePeersTarget) this.offlinePeersTarget.textContent = offline
  }

  updatePeers(peers) {
    if (!this.hasPeersTableTarget || !peers) return

    // Simple re-render — in production you'd diff and update individual rows
    const tbody = this.peersTableTarget
    tbody.innerHTML = peers.map(peer => `
      <tr class="hover:bg-gray-750">
        <td class="px-6 py-4 font-medium text-white">${peer.name || "Unknown"}</td>
        <td class="px-6 py-4 text-gray-400 font-mono text-xs">${peer.destination_hash}</td>
        <td class="px-6 py-4 text-gray-300">${peer.hops || 0}</td>
        <td class="px-6 py-4">
          <div class="flex items-center">
            <div class="w-16 bg-gray-700 rounded-full h-2 mr-2">
              <div class="bg-${this.qualityColor(peer.link_quality)}-500 h-2 rounded-full" style="width: ${Math.round((peer.link_quality || 0) * 100)}%"></div>
            </div>
            <span class="text-gray-300 text-xs">${Math.round((peer.link_quality || 0) * 100)}%</span>
          </div>
        </td>
        <td class="px-6 py-4">
          <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${this.statusBadgeClass(peer.status)}">
            ${peer.status}
          </span>
        </td>
        <td class="px-6 py-4 text-gray-400">${this.formatLastSeen(peer.last_seen)}</td>
      </tr>
    `).join("")
  }

  updateInterfaces(interfaces) {
    if (!this.hasInterfacesGridTarget || !interfaces) return

    this.interfacesGridTarget.innerHTML = interfaces.map(iface => `
      <div class="bg-gray-750 rounded-lg p-4 border border-gray-700">
        <div class="flex items-center justify-between mb-2">
          <h3 class="font-medium text-white">${iface.name}</h3>
          <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium ${this.ifaceStatusBadgeClass(iface.status)}">
            ${iface.status}
          </span>
        </div>
        <p class="text-xs text-gray-400 mb-3">${iface.interface_type}</p>
        <div class="space-y-1 text-xs">
          <div class="flex justify-between text-gray-400">
            <span>Bandwidth</span>
            <span class="text-gray-300">${this.formatBandwidth(iface.bandwidth_in, iface.bandwidth_out)}</span>
          </div>
          <div class="flex justify-between text-gray-400">
            <span>Uptime</span>
            <span class="text-gray-300">${this.formatUptime(iface.uptime)}</span>
          </div>
          <div class="flex justify-between text-gray-400">
            <span>Error Rate</span>
            <span class="text-gray-300">${iface.error_rate ? (iface.error_rate * 100).toFixed(2) + "%" : "—"}</span>
          </div>
        </div>
      </div>
    `).join("")
  }

  updateConnectionStatus(connected) {
    if (!this.hasConnectionStatusTarget || !this.hasConnectionTextTarget) return

    if (connected) {
      this.connectionStatusTarget.className = "w-2 h-2 rounded-full bg-green-500 mr-2"
      this.connectionTextTarget.textContent = "Connected"
    } else {
      this.connectionStatusTarget.className = "w-2 h-2 rounded-full bg-red-500 mr-2"
      this.connectionTextTarget.textContent = "Disconnected"
    }
  }

  qualityColor(quality) {
    if (!quality) return "gray"
    if (quality >= 0.8) return "green"
    if (quality >= 0.5) return "yellow"
    return "red"
  }

  statusBadgeClass(status) {
    switch (status) {
      case "active": return "bg-green-100 text-green-800"
      case "degraded": return "bg-yellow-100 text-yellow-800"
      case "offline": return "bg-red-100 text-red-800"
      default: return "bg-gray-100 text-gray-800"
    }
  }

  ifaceStatusBadgeClass(status) {
    switch (status) {
      case "up": return "bg-green-100 text-green-800"
      case "down": return "bg-gray-100 text-gray-800"
      case "error": return "bg-red-100 text-red-800"
      default: return "bg-yellow-100 text-yellow-800"
    }
  }

  formatLastSeen(lastSeen) {
    if (!lastSeen) return "never"
    const date = new Date(lastSeen)
    const now = new Date()
    const diff = Math.floor((now - date) / 1000)
    if (diff < 60) return "just now"
    if (diff < 3600) return `${Math.floor(diff / 60)}m ago`
    if (diff < 86400) return `${Math.floor(diff / 3600)}h ago`
    return `${Math.floor(diff / 86400)}d ago`
  }

  formatBandwidth(inBytes, outBytes) {
    const fmt = (b) => {
      if (!b) return "0B"
      if (b < 1024) return `${b}B`
      if (b < 1024 * 1024) return `${(b / 1024).toFixed(1)}KB`
      return `${(b / (1024 * 1024)).toFixed(1)}MB`
    }
    return `↓${fmt(inBytes)} ↑${fmt(outBytes)}`
  }

  formatUptime(seconds) {
    if (!seconds || seconds <= 0) return "—"
    const h = Math.floor(seconds / 3600)
    const m = Math.floor((seconds % 3600) / 60)
    return `${h}h ${m}m`
  }
}
