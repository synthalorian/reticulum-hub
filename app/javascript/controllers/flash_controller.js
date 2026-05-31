import { Controller } from "@hotwired/stimulus"

// FlashController auto-dismisses flash messages after 5 seconds.
//
export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, 5000)
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  dismiss() {
    this.element.style.opacity = "0"
    this.element.style.transition = "opacity 0.3s ease"
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
