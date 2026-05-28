# Reticulum Hub — Implementation Plan

## Overview

Phased implementation plan for Reticulum Hub, a Rails 8 web dashboard for Reticulum mesh network management.

## Phase 1: Foundation (Weeks 1–2)

**Goal:** Bootable Rails 8 app with RNS adapter, basic dashboard, and peer listing.

### Tasks
- [ ] Initialize Rails 8 app with SQLite, Tailwind CSS, Hotwire
- [ ] Create `RnsAdapter` service object — connect to rnsd via TCP/Unix socket
- [ ] Implement connection pooling with automatic reconnection
- [ ] Define event parser for RNS status output
- [ ] Build `Peer` model (destination hash, name, last_seen, link_quality, hops)
- [ ] Build `Interface` model (name, type, status, config_json)
- [ ] Dashboard controller with index action showing:
  - Connected peers table
  - Interface status cards
  - Basic network stats (total peers, active links, uptime)
- [ ] Tailwind-styled dashboard layout with sidebar navigation
- [ ] `bin/setup` script to handle dependencies

### File Touchpoints
```
app/models/peer.rb
app/models/interface.rb
app/services/rns_adapter.rb
app/controllers/dashboard_controller.rb
app/views/dashboard/index.html.erb
app/views/layouts/application.html.erb
config/routes.rb
db/migrate/001_create_peers.rb
db/migrate/002_create_interfaces.rb
```

## Phase 2: Real-Time Updates (Weeks 3–4)

**Goal:** WebSocket-driven live updates for peers, interfaces, and network stats.

### Tasks
- [ ] Action Cable channel: `NetworkChannel` — broadcasts peer/interface changes
- [ ] Background job (Solid Queue) polling rnsd for status every 5 seconds
- [ ] Stimulus controller: `network-status` — updates DOM on WebSocket events
- [ ] Live peer table with sorting, filtering, and quality indicators
- [ ] Interface cards with real-time bandwidth graphs (via Stimulus + Canvas)
- [ ] Connection status indicator (green/yellow/red for rnsd health)
- [ ] Add `SystemStats` model — cpu, memory, bandwidth, uptime snapshots

### File Touchpoints
```
app/channels/network_channel.rb
app/javascript/controllers/network_status_controller.js
app/javascript/controllers/bandwidth_graph_controller.js
app/jobs/rns_poll_job.rb
app/models/system_stat.rb
```

## Phase 3: LXMF Web Client (Weeks 5–7)

**Goal:** Full bidirectional LXMF messaging from the browser.

### Tasks
- [ ] `Message` model (sender, recipient, subject, body, sent_at, delivered, read)
- [ ] `LxmfAdapter` service — send/receive LXMF messages via rnsd
- [ ] Inbox view — list conversations with unread badges
- [ ] Conversation view — threaded message history
- [ ] Compose view — recipient autocomplete (from known peers), rich text body
- [ ] Action Cable channel: `MessagesChannel` — push new messages to browser
- [ ] File attachment support — upload → send via LXMF file transfer
- [ ] Message status tracking (sent → delivered → read)
- [ ] Draft auto-save with localStorage

### File Touchpoints
```
app/models/message.rb
app/models/conversation.rb
app/services/lxmf_adapter.rb
app/controllers/messages_controller.rb
app/channels/messages_channel.rb
app/views/messages/index.html.erb
app/views/messages/show.html.erb
app/views/messages/compose.html.erb
app/javascript/controllers/compose_controller.js
db/migrate/003_create_messages.rb
db/migrate/004_create_conversations.rb
```

## Phase 4: Network Explorer & Topology (Weeks 8–9)

**Goal:** Interactive network map and service discovery.

### Tasks
- [ ] `NetworkMap` service — build graph from peer/link data
- [ ] Topology visualization — SVG/Canvas-based force-directed graph
- [ ] Node detail panel — click a node to see services, paths, uptime
- [ ] Path tracing — show hops between any two nodes
- [ ] Service registry — discovered services from announces
- [ ] Announce management — send/edit/custom announces
- [ ] `Node` and `Service` models for persistent discovery data

### File Touchpoints
```
app/services/network_map.rb
app/models/node.rb
app/models/service.rb
app/controllers/explorer_controller.rb
app/controllers/announces_controller.rb
app/views/explorer/index.html.erb
app/javascript/controllers/topology_map_controller.js
db/migrate/005_create_nodes.rb
db/migrate/006_create_services.rb
```

## Phase 5: Interface Management (Weeks 10–11)

**Goal:** Full CRUD for Reticulum interfaces from the web UI.

### Tasks
- [ ] Interface configuration editor — form-based config for each interface type
- [ ] Interface type templates: AutoInterface, TCPClient, TCPServer, Serial, RNode, LoRa
- [ ] Enable/disable interfaces without daemon restart
- [ ] Interface testing — ping through a specific interface
- [ ] Interface logs — per-interface event stream with filtering
- [ ] Bulk configuration import/export (JSON/YAML)
- [ ] Config validation before apply

### File Touchpoints
```
app/controllers/interfaces_controller.rb
app/views/interfaces/edit.html.erb
app/services/interface_manager.rb
app/javascript/controllers/interface_editor_controller.js
```

## Phase 6: Alerting & Notifications (Weeks 12–13)

**Goal:** Configurable alerts for network events.

### Tasks
- [ ] `AlertRule` model — condition, threshold, notification channels
- [ ] `Alert` model — triggered alerts with status (active, acknowledged, resolved)
- [ ] Alert evaluation engine — runs rules against live network data
- [ ] Notification dispatchers: email, webhook, LXMF message
- [ ] Alert history view with filtering and bulk actions
- [ ] Default alert templates (peer down, quality degraded, interface error)
- [ ] Action Cable channel: `AlertsChannel` — real-time alert popups

### File Touchpoints
```
app/models/alert_rule.rb
app/models/alert.rb
app/services/alert_engine.rb
app/services/notifiers/email_notifier.rb
app/services/notifiers/webhook_notifier.rb
app/services/notifiers/lxmf_notifier.rb
app/controllers/alerts_controller.rb
app/channels/alerts_channel.rb
db/migrate/007_create_alert_rules.rb
db/migrate/008_create_alerts.rb
```

## Phase 7: Polish & Release (Weeks 14–15)

**Goal:** Production-ready v1.0 release.

### Tasks
- [ ] Comprehensive test suite (RSpec — system specs, request specs)
- [ ] Dockerfile for containerized deployment
- [ ] Installation guide and user documentation
- [ ] API documentation (for third-party integrations)
- [ ] Performance optimization — caching, query optimization
- [ ] Accessibility audit (WCAG 2.1 AA)
- [ ] Security review — CSRF, XSS, input validation
- [ ] GitHub Actions CI pipeline
- [ ] Release v1.0.0

## Success Metrics

| Metric | Target |
|--------|--------|
| Dashboard load time | < 500ms |
| WebSocket update latency | < 1s |
| Peer discovery refresh | < 5s |
| Message send latency | < 2s (local) |
| Test coverage | > 80% |
| Uptime | 99.9% |
