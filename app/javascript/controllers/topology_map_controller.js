import { Controller } from "@hotwired/stimulus"

// TopologyMapController renders a force-directed network graph
// using HTML5 Canvas. Nodes are discovered Reticulum peers, edges
// represent connectivity paths.
//
export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    nodes: Array,
    edges: Array
  }

  connect() {
    this.canvas = this.hasCanvasTarget ? this.canvasTarget : this.element.querySelector("canvas")
    if (!this.canvas) return

    this.ctx = this.canvas.getContext("2d")
    this.resize()

    this.nodeRadius = 8
    this.hoveredNode = null
    this.draggedNode = null
    this.simulationRunning = true

    // Initialize node positions in a circle
    this.initPositions()

    // Start animation loop
    this.animate()

    // Event listeners
    this.canvas.addEventListener("mousemove", this.handleMouseMove.bind(this))
    this.canvas.addEventListener("mousedown", this.handleMouseDown.bind(this))
    this.canvas.addEventListener("mouseup", this.handleMouseUp.bind(this))
    this.canvas.addEventListener("mouseleave", this.handleMouseUp.bind(this))
    window.addEventListener("resize", this.resize.bind(this))
  }

  disconnect() {
    this.simulationRunning = false
    window.removeEventListener("resize", this.resize)
  }

  resize() {
    const parent = this.canvas.parentElement
    this.canvas.width = parent.clientWidth
    this.canvas.height = parent.clientHeight
    this.width = this.canvas.width
    this.height = this.canvas.height
  }

  initPositions() {
    const nodes = this.nodesValue
    const count = nodes.length
    const cx = this.width / 2
    const cy = this.height / 2
    const radius = Math.min(this.width, this.height) * 0.35

    this.nodes = nodes.map((node, i) => {
      const angle = (2 * Math.PI * i) / Math.max(count, 1)
      return {
        ...node,
        x: cx + radius * Math.cos(angle),
        y: cy + radius * Math.sin(angle),
        vx: 0,
        vy: 0
      }
    })

    this.edges = this.edgesValue.map(edge => ({
      ...edge,
      source: this.nodes.find(n => n.id === edge.source) || this.nodes[0],
      target: this.nodes.find(n => n.id === edge.target) || this.nodes[0]
    }))
  }

  animate() {
    if (!this.simulationRunning) return

    this.updatePhysics()
    this.draw()
    requestAnimationFrame(this.animate.bind(this))
  }

  updatePhysics() {
    const k = 0.05 // spring constant
    const repulsion = 2000
    const damping = 0.9
    const centerForce = 0.01

    const cx = this.width / 2
    const cy = this.height / 2

    // Repulsion between nodes
    for (let i = 0; i < this.nodes.length; i++) {
      for (let j = i + 1; j < this.nodes.length; j++) {
        const a = this.nodes[i]
        const b = this.nodes[j]
        const dx = b.x - a.x
        const dy = b.y - a.y
        const dist = Math.sqrt(dx * dx + dy * dy) || 1
        const force = repulsion / (dist * dist)
        const fx = (dx / dist) * force
        const fy = (dy / dist) * force

        a.vx -= fx
        a.vy -= fy
        b.vx += fx
        b.vy += fy
      }
    }

    // Spring force along edges
    this.edges.forEach(edge => {
      const a = edge.source
      const b = edge.target
      const dx = b.x - a.x
      const dy = b.y - a.y
      const dist = Math.sqrt(dx * dx + dy * dy) || 1
      const force = k * (dist - 80)
      const fx = (dx / dist) * force
      const fy = (dy / dist) * force

      a.vx += fx
      a.vy += fy
      b.vx -= fx
      b.vy -= fy
    })

    // Center gravity
    this.nodes.forEach(node => {
      if (node === this.draggedNode) return
      node.vx += (cx - node.x) * centerForce
      node.vy += (cy - node.y) * centerForce
      node.vx *= damping
      node.vy *= damping
      node.x += node.vx
      node.y += node.vy

      // Keep in bounds
      node.x = Math.max(this.nodeRadius, Math.min(this.width - this.nodeRadius, node.x))
      node.y = Math.max(this.nodeRadius, Math.min(this.height - this.nodeRadius, node.y))
    })
  }

  draw() {
    const ctx = this.ctx
    ctx.clearRect(0, 0, this.width, this.height)

    // Draw grid background
    this.drawGrid(ctx)

    // Draw edges
    this.edges.forEach(edge => {
      const a = edge.source
      const b = edge.target
      ctx.beginPath()
      ctx.moveTo(a.x, a.y)
      ctx.lineTo(b.x, b.y)
      ctx.strokeStyle = "rgba(139, 92, 246, 0.3)"
      ctx.lineWidth = 1
      ctx.stroke()
    })

    // Draw nodes
    this.nodes.forEach(node => {
      const isHovered = node === this.hoveredNode
      const isLocal = node.hops === 0

      // Glow effect
      if (isHovered || isLocal) {
        ctx.beginPath()
        ctx.arc(node.x, node.y, this.nodeRadius + 6, 0, 2 * Math.PI)
        ctx.fillStyle = isLocal ? "rgba(34, 211, 238, 0.2)" : "rgba(139, 92, 246, 0.2)"
        ctx.fill()
      }

      // Node circle
      ctx.beginPath()
      ctx.arc(node.x, node.y, this.nodeRadius, 0, 2 * Math.PI)
      ctx.fillStyle = isLocal ? "#22d3ee" : this.statusColor(node.status)
      ctx.fill()

      // Border
      ctx.strokeStyle = isHovered ? "#fff" : "rgba(255,255,255,0.3)"
      ctx.lineWidth = isHovered ? 2 : 1
      ctx.stroke()

      // Label
      ctx.fillStyle = "#e5e7eb"
      ctx.font = "11px ui-monospace, SFMono-Regular, Menlo, monospace"
      ctx.textAlign = "center"
      ctx.fillText(node.name || node.id.slice(0, 8), node.x, node.y + this.nodeRadius + 14)
    })
  }

  drawGrid(ctx) {
    const step = 40
    ctx.strokeStyle = "rgba(75, 85, 99, 0.15)"
    ctx.lineWidth = 0.5

    for (let x = 0; x < this.width; x += step) {
      ctx.beginPath()
      ctx.moveTo(x, 0)
      ctx.lineTo(x, this.height)
      ctx.stroke()
    }
    for (let y = 0; y < this.height; y += step) {
      ctx.beginPath()
      ctx.moveTo(0, y)
      ctx.lineTo(this.width, y)
      ctx.stroke()
    }
  }

  statusColor(status) {
    switch (status) {
      case "active": return "#10b981"
      case "degraded": return "#f59e0b"
      case "offline": return "#ef4444"
      default: return "#6b7280"
    }
  }

  getMousePos(e) {
    const rect = this.canvas.getBoundingClientRect()
    return {
      x: e.clientX - rect.left,
      y: e.clientY - rect.top
    }
  }

  handleMouseMove(e) {
    const pos = this.getMousePos(e)

    if (this.draggedNode) {
      this.draggedNode.x = pos.x
      this.draggedNode.y = pos.y
      this.draggedNode.vx = 0
      this.draggedNode.vy = 0
      return
    }

    this.hoveredNode = null
    for (const node of this.nodes) {
      const dx = pos.x - node.x
      const dy = pos.y - node.y
      if (Math.sqrt(dx * dx + dy * dy) < this.nodeRadius + 4) {
        this.hoveredNode = node
        this.canvas.style.cursor = "pointer"
        return
      }
    }
    this.canvas.style.cursor = "default"
  }

  handleMouseDown(e) {
    if (this.hoveredNode) {
      this.draggedNode = this.hoveredNode
    }
  }

  handleMouseUp() {
    this.draggedNode = null
  }
}
