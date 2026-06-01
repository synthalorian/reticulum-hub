import { Controller } from "@hotwired/stimulus"

// SparklineController renders a live-updating canvas sparkline
// for bandwidth, cpu, memory, or any numeric metric.
//
// Usage:
//   <canvas data-controller="sparkline"
//           data-sparkline-values-value="[10,20,30,25,40]"
//           data-sparkline-color-value="#39ff14">
//
export default class extends Controller {
  static values = {
    values: Array,
    color: { type: String, default: "#39ff14" },
    maxPoints: { type: Number, default: 60 }
  }

  connect() {
    this.canvas = this.element
    this.ctx = this.canvas.getContext("2d")
    this.resize()

    this.data = this.valuesValue.length > 0 ? [...this.valuesValue] : new Array(this.maxPointsValue).fill(0)
    this.draw()

    window.addEventListener("resize", this.resize.bind(this))
  }

  disconnect() {
    window.removeEventListener("resize", this.resize)
  }

  resize() {
    const parent = this.canvas.parentElement
    this.canvas.width = parent.clientWidth
    this.canvas.height = parent.clientHeight
    this.width = this.canvas.width
    this.height = this.canvas.height
    this.draw()
  }

  add(value) {
    this.data.push(value)
    if (this.data.length > this.maxPointsValue) {
      this.data.shift()
    }
    this.draw()
  }

  draw() {
    const ctx = this.ctx
    const w = this.width
    const h = this.height
    const data = this.data

    ctx.clearRect(0, 0, w, h)

    if (data.length < 2) return

    const max = Math.max(...data, 1)
    const min = Math.min(...data, 0)
    const range = max - min || 1

    // Area fill
    ctx.beginPath()
    ctx.moveTo(0, h)
    data.forEach((val, i) => {
      const x = (i / (data.length - 1)) * w
      const y = h - ((val - min) / range) * h * 0.9 - h * 0.05
      ctx.lineTo(x, y)
    })
    ctx.lineTo(w, h)
    ctx.closePath()

    const gradient = ctx.createLinearGradient(0, 0, 0, h)
    gradient.addColorStop(0, this.colorValue + "40")
    gradient.addColorStop(1, this.colorValue + "00")
    ctx.fillStyle = gradient
    ctx.fill()

    // Line
    ctx.beginPath()
    data.forEach((val, i) => {
      const x = (i / (data.length - 1)) * w
      const y = h - ((val - min) / range) * h * 0.9 - h * 0.05
      if (i === 0) ctx.moveTo(x, y)
      else ctx.lineTo(x, y)
    })
    ctx.strokeStyle = this.colorValue
    ctx.lineWidth = 2
    ctx.stroke()

    // Glow
    ctx.shadowColor = this.colorValue
    ctx.shadowBlur = 8
    ctx.stroke()
    ctx.shadowBlur = 0
  }
}
