import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle"]

  connect() {
    this.theme = localStorage.getItem("theme") || "dark"
    this.apply()
  }

  toggle() {
    this.theme = this.theme === "dark" ? "light" : "dark"
    localStorage.setItem("theme", this.theme)
    this.apply()
  }

  apply() {
    const html = document.documentElement
    if (this.theme === "light") {
      html.classList.add("light")
      html.classList.remove("dark")
    } else {
      html.classList.add("dark")
      html.classList.remove("light")
    }

    // Update toggle icon if present
    if (this.hasToggleTarget) {
      this.toggleTarget.innerHTML = this.theme === "dark"
        ? `<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"/></svg>`
        : `<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"/></svg>`
    }
  }
}
