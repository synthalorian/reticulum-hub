import { Controller } from "@hotwired/stimulus"

// KeyboardShortcutsController provides vim-style navigation
// g + d = Dashboard, g + m = Messages, g + i = Interfaces,
// g + e = Explorer, g + a = Alerts, g + s = Settings
// j/k = scroll down/up, / = focus search (if present)
//
export default class extends Controller {
  connect() {
    this.sequence = ""
    this.bufferTimeout = null
    this.boundHandler = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.boundHandler)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandler)
  }

  handleKeydown(e) {
    // Ignore if typing in an input/textarea
    if (e.target.matches("input, textarea, [contenteditable]")) return

    const key = e.key.toLowerCase()

    // Buffer sequence for "g" commands
    if (this.sequence === "g") {
      this.sequence = ""
      clearTimeout(this.bufferTimeout)

      const routes = {
        d: "/dashboard",
        m: "/messages",
        i: "/interfaces",
        e: "/explorer",
        a: "/alerts",
        s: "/settings"
      }

      if (routes[key]) {
        e.preventDefault()
        window.location.href = routes[key]
        return
      }
    }

    if (key === "g") {
      e.preventDefault()
      this.sequence = "g"
      this.bufferTimeout = setTimeout(() => { this.sequence = "" }, 800)
      return
    }

    // Scroll
    if (key === "j") {
      e.preventDefault()
      window.scrollBy({ top: 60, behavior: "smooth" })
      return
    }
    if (key === "k") {
      e.preventDefault()
      window.scrollBy({ top: -60, behavior: "smooth" })
      return
    }

    // Focus search if present
    if (key === "/") {
      const search = document.querySelector("[data-keyboard-shortcuts-target='search']")
      if (search) {
        e.preventDefault()
        search.focus()
      }
      return
    }

    // Escape clears
    if (key === "escape") {
      this.sequence = ""
      clearTimeout(this.bufferTimeout)
    }
  }
}
