import { Controller } from "@hotwired/stimulus"

// MobileSidebarController toggles the sidebar on small screens.
//
export default class extends Controller {
  static targets = ["sidebar", "overlay"]

  connect() {
    this.isOpen = false
  }

  toggle() {
    this.isOpen = !this.isOpen
    this.update()
  }

  open() {
    this.isOpen = true
    this.update()
  }

  close() {
    this.isOpen = false
    this.update()
  }

  update() {
    if (this.isOpen) {
      this.sidebarTarget.classList.remove("-translate-x-full")
      this.sidebarTarget.classList.add("translate-x-0")
      if (this.hasOverlayTarget) {
        this.overlayTarget.classList.remove("hidden")
      }
      document.body.style.overflow = "hidden"
    } else {
      this.sidebarTarget.classList.remove("translate-x-0")
      this.sidebarTarget.classList.add("-translate-x-full")
      if (this.hasOverlayTarget) {
        this.overlayTarget.classList.add("hidden")
      }
      document.body.style.overflow = ""
    }
  }
}
