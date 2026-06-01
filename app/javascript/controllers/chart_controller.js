import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    type: String,
    data: Array,
    color: { type: String, default: "#00F0FF" }
  }

  connect() {
    this.canvas = document.createElement("canvas")
    this.canvas.width = this.element.clientWidth
    this.canvas.height = this.element.clientHeight
    this.element.appendChild(this.canvas)
    this.ctx = this.canvas.getContext("2d")

    this.resizeObserver = new ResizeObserver(() => this.draw())
    this.resizeObserver.observe(this.element)

    this.draw()
  }

  disconnect() {
    this.resizeObserver?.disconnect()
  }

  draw() {
    const canvas = this.canvas
    const ctx = this.ctx
    const data = this.dataValue || []
    const color = this.colorValue
    const type = this.typeValue

    canvas.width = this.element.clientWidth
    canvas.height = this.element.clientHeight

    const w = canvas.width
    const h = canvas.height
    const padding = 40
    const chartW = w - padding * 2
    const chartH = h - padding * 2

    ctx.clearRect(0, 0, w, h)

    if (data.length === 0) {
      ctx.fillStyle = "#6b7280"
      ctx.font = "14px sans-serif"
      ctx.textAlign = "center"
      ctx.fillText("No data available", w / 2, h / 2)
      return
    }

    const values = data.map(([, v]) => v)
    const minVal = Math.min(...values) * 0.9
    const maxVal = Math.max(...values) * 1.1
    const range = maxVal - minVal || 1

    // Grid lines
    ctx.strokeStyle = "#374151"
    ctx.lineWidth = 0.5
    for (let i = 0; i <= 5; i++) {
      const y = padding + (chartH / 5) * i
      ctx.beginPath()
      ctx.moveTo(padding, y)
      ctx.lineTo(w - padding, y)
      ctx.stroke()

      const label = (maxVal - (range / 5) * i).toFixed(1)
      ctx.fillStyle = "#9ca3af"
      ctx.font = "10px sans-serif"
      ctx.textAlign = "right"
      ctx.fillText(label, padding - 8, y + 3)
    }

    // Data
    const stepX = chartW / (data.length - 1 || 1)

    if (type === "bar") {
      const barW = Math.max(2, chartW / data.length * 0.8)
      data.forEach(([, v], i) => {
        const barH = ((v - minVal) / range) * chartH
        const x = padding + i * (chartW / data.length) + barW * 0.1
        const y = padding + chartH - barH

        ctx.fillStyle = color + "80"
        ctx.fillRect(x, y, barW, barH)

        ctx.strokeStyle = color
        ctx.lineWidth = 1
        ctx.strokeRect(x, y, barW, barH)
      })
    } else {
      // Line or area
      ctx.beginPath()
      data.forEach(([, v], i) => {
        const x = padding + i * stepX
        const y = padding + chartH - ((v - minVal) / range) * chartH
        if (i === 0) ctx.moveTo(x, y)
        else ctx.lineTo(x, y)
      })

      if (type === "area") {
        ctx.lineTo(padding + (data.length - 1) * stepX, padding + chartH)
        ctx.lineTo(padding, padding + chartH)
        ctx.closePath()
        const grad = ctx.createLinearGradient(0, padding, 0, padding + chartH)
        grad.addColorStop(0, color + "40")
        grad.addColorStop(1, color + "05")
        ctx.fillStyle = grad
        ctx.fill()
      }

      ctx.strokeStyle = color
      ctx.lineWidth = 2
      ctx.stroke()

      // Glow
      ctx.shadowColor = color
      ctx.shadowBlur = 10
      ctx.stroke()
      ctx.shadowBlur = 0

      // Points
      data.forEach(([, v], i) => {
        const x = padding + i * stepX
        const y = padding + chartH - ((v - minVal) / range) * chartH
        ctx.beginPath()
        ctx.arc(x, y, 3, 0, Math.PI * 2)
        ctx.fillStyle = color
        ctx.fill()
      })
    }
  }
}
