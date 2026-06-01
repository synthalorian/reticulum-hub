import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "tbody", "indicator", "statusText"]
  static values = {
    url: String,
    lastId: { type: Number, default: 0 }
  }

  connect() {
    this.lastId = this.lastIdValue
    this.startStream()
    this.scrollToBottom()
  }

  disconnect() {
    this.stopStream()
  }

  startStream() {
    if (this.eventSource) return

    const url = new URL(this.urlValue || "/logs/stream", window.location.origin)
    url.searchParams.set("last_id", this.lastId)

    this.eventSource = new EventSource(url.toString())

    this.eventSource.addEventListener("log", (event) => {
      const data = JSON.parse(event.data)
      this.appendLog(data)
      this.lastId = data.id
    })

    this.eventSource.addEventListener("error", () => {
      this.indicatorTarget.classList.remove("bg-green-500", "animate-pulse")
      this.indicatorTarget.classList.add("bg-red-500")
      this.statusTextTarget.textContent = "Disconnected"

      // Reconnect after 3s
      setTimeout(() => this.startStream(), 3000)
    })

    this.eventSource.addEventListener("open", () => {
      this.indicatorTarget.classList.remove("bg-red-500")
      this.indicatorTarget.classList.add("bg-green-500", "animate-pulse")
      this.statusTextTarget.textContent = "Live"
    })
  }

  stopStream() {
    if (this.eventSource) {
      this.eventSource.close()
      this.eventSource = null
    }
  }

  appendLog(data) {
    const row = document.createElement("tr")
    row.className = "hover:bg-gray-700/50 transition-colors animate-fade-in"
    row.innerHTML = `
      <td class="px-4 py-2 text-gray-400 whitespace-nowrap font-mono text-xs">${this.formatTime(data.timestamp)}</td>
      <td class="px-4 py-2">
        <span class="inline-flex px-2 py-0.5 text-xs font-medium border rounded ${data.badge_class}">${data.level.toUpperCase()}</span>
      </td>
      <td class="px-4 py-2 text-gray-400 whitespace-nowrap">${data.source}</td>
      <td class="px-4 py-2 ${data.color_class}">${this.escapeHtml(data.message)}</td>
    `

    this.tbodyTarget.insertBefore(row, this.tbodyTarget.firstChild)

    // Keep max 500 rows
    while (this.tbodyTarget.children.length > 500) {
      this.tbodyTarget.lastChild.remove()
    }

    // Auto-scroll if near bottom
    const container = this.containerTarget
    const nearBottom = container.scrollHeight - container.scrollTop - container.clientHeight < 100
    if (nearBottom) {
      this.scrollToBottom()
    }
  }

  scrollToBottom() {
    this.containerTarget.scrollTop = this.containerTarget.scrollHeight
  }

  formatTime(iso) {
    const d = new Date(iso)
    return d.toTimeString().split(" ")[0] + "." + String(d.getMilliseconds()).padStart(3, "0")
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
