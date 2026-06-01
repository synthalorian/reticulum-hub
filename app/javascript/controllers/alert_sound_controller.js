import { Controller } from "@hotwired/stimulus"

// AlertSoundController plays audio notifications for critical alerts
// using the Web Audio API (no external files needed).
//
// Usage:
//   <div data-controller="alert-sound"
//        data-alert-sound-enabled-value="true"
//        data-alert-sound-severity-value="critical">
//
export default class extends Controller {
  static values = {
    enabled: { type: Boolean, default: true },
    severity: { type: String, default: "critical" }
  }

  connect() {
    this.audioCtx = null
  }

  disconnect() {
    if (this.audioCtx) {
      this.audioCtx.close()
    }
  }

  play() {
    if (!this.enabledValue) return

    this.audioCtx = new (window.AudioContext || window.webkitAudioContext)()

    switch (this.severityValue) {
      case "critical":
        this.playCritical()
        break
      case "error":
        this.playError()
        break
      case "warning":
        this.playWarning()
        break
      default:
        this.playInfo()
    }
  }

  playCritical() {
    // Three descending beeps — urgent
    const now = this.audioCtx.currentTime
    ;[880, 660, 440].forEach((freq, i) => {
      this.beep(freq, now + i * 0.15, 0.12)
    })
  }

  playError() {
    // Two flat beeps
    const now = this.audioCtx.currentTime
    ;[660, 660].forEach((freq, i) => {
      this.beep(freq, now + i * 0.2, 0.15)
    })
  }

  playWarning() {
    // Single rising tone
    this.sweep(440, 660, this.audioCtx.currentTime, 0.25)
  }

  playInfo() {
    // Gentle ping
    this.beep(880, this.audioCtx.currentTime, 0.1)
  }

  beep(frequency, startTime, duration) {
    const osc = this.audioCtx.createOscillator()
    const gain = this.audioCtx.createGain()

    osc.type = "square"
    osc.frequency.setValueAtTime(frequency, startTime)

    gain.gain.setValueAtTime(0.08, startTime)
    gain.gain.exponentialRampToValueAtTime(0.001, startTime + duration)

    osc.connect(gain)
    gain.connect(this.audioCtx.destination)

    osc.start(startTime)
    osc.stop(startTime + duration)
  }

  sweep(startFreq, endFreq, startTime, duration) {
    const osc = this.audioCtx.createOscillator()
    const gain = this.audioCtx.createGain()

    osc.type = "sine"
    osc.frequency.setValueAtTime(startFreq, startTime)
    osc.frequency.linearRampToValueAtTime(endFreq, startTime + duration)

    gain.gain.setValueAtTime(0.08, startTime)
    gain.gain.exponentialRampToValueAtTime(0.001, startTime + duration)

    osc.connect(gain)
    gain.connect(this.audioCtx.destination)

    osc.start(startTime)
    osc.stop(startTime + duration)
  }
}
