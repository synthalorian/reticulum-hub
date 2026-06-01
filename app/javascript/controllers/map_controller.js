import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]
  static values = {
    peers: { type: Array, default: [] }
  }

  connect() {
    if (typeof L === "undefined") {
      console.warn("Leaflet not loaded yet, retrying...")
      setTimeout(() => this.connect(), 500)
      return
    }

    this.map = L.map(this.containerTarget).setView([39.8283, -98.5795], 4)

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: "&copy; OpenStreetMap",
      maxZoom: 18
    }).addTo(this.map)

    this.peersValue.forEach(peer => {
      const color = peer.status === "active" ? "#00F0FF" :
                    peer.status === "degraded" ? "#F3E70F" : "#FF7EDB"

      const marker = L.circleMarker([peer.lat, peer.lng], {
        radius: 8 + (peer.quality || 0.5) * 8,
        fillColor: color,
        color: color,
        weight: 2,
        opacity: 0.8,
        fillOpacity: 0.6
      }).addTo(this.map)

      marker.bindPopup(`
        <div style="color:#1f2937">
          <strong>${peer.name}</strong><br/>
          <code>${peer.hash}</code><br/>
          Quality: ${(peer.quality * 100).toFixed(0)}%<br/>
          ${peer.location || ""}
        </div>
      `)
    })

    if (this.peersValue.length > 0) {
      const bounds = this.peersValue.map(p => [p.lat, p.lng])
      this.map.fitBounds(bounds, { padding: [50, 50] })
    }
  }

  disconnect() {
    this.map?.remove()
  }
}
