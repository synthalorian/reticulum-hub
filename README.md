# ⊛ Reticulum Hub

> Web dashboard and management platform for [Reticulum](https://reticulum.network/) networks

```
    ╔══════════════════════════════════════════════════════════════╗
    ║                    R E T I C U L U M   H U B               ║
    ║                                                              ║
    ║   ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   ║
    ║   │  Browser │  │  Browser │  │  Browser │  │  Mobile  │   ║
    ║   └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   ║
    ║        │              │              │              │         ║
    ║   ═════╪══════════════╪══════════════╪══════════════╪════    ║
    ║        │         Hotwire / Turbo     │              │         ║
    ║   ┌────┴─────────────┴──────────────┴──────────────┴─────┐  ║
    ║   │                    Rails 8 Server                     │  ║
    ║   │  ┌─────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ │  ║
    ║   │  │Dashboard│ │LXMF Msgs │ │ Interface│ │ Network  │ │  ║
    ║   │  │  Engine  │ │  Engine  │ │  Engine  │ │ Explorer  │ │  ║
    ║   │  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘ │  ║
    ║   │       │            │            │            │        │  ║
    ║   │  ┌────┴────────────┴────────────┴────────────┴─────┐  │  ║
    ║   │  │              RNS Daemon Adapter                  │  │  ║
    ║   │  │        (Unix socket / TCP connection)            │  │  ║
    ║   │  └─────────────────────┬───────────────────────────┘  │  ║
    ║   └────────────────────────┼──────────────────────────────┘  ║
    ║                            │                                 ║
    ║                   ┌────────┴────────┐                       ║
    ║                   │   rnsd (RNS)    │                       ║
    ║                   │  Reticulum Net  │                       ║
    ║                   └────────┬────────┘                       ║
    ║                            │                                 ║
    ║              ┌─────────────┼─────────────┐                  ║
    ║         ┌────┴───┐   ┌────┴───┐   ┌────┴───┐              ║
    ║         │  LoRa  │   │  TCP   │   │  USB   │              ║
    ║         │ Radio  │   │ Peers  │   │ Serial │              ║
    ║         └────────┘   └────────┘   └────────┘              ║
    ╚══════════════════════════════════════════════════════════════╝
```

## Overview

Reticulum Hub is a full-featured web dashboard for managing and monitoring Reticulum mesh networks. It connects to a running `rnsd` daemon and provides real-time visibility into your network topology, peer status, link quality, and LXMF messaging — all from your browser.

Built with **Ruby on Rails 8**, **Hotwire** (Turbo + Stimulus), **Tailwind CSS**, and **SQLite** — no JavaScript build step required.

## Features

### 🖥️ Real-Time Dashboard
- **Network topology map** — interactive visualization of nodes, links, and hops
- **Active peers** — live table of connected peers with signal quality
- **Link quality metrics** — SNR, RSSI, packet loss, and latency graphs
- **System status** — CPU, memory, bandwidth usage of the transport node

### ✉️ LXMF Web Client
- **Encrypted messaging** — send and receive LXMF messages from the browser
- **Conversation threads** — organized message history per peer
- **File attachments** — transfer files over the mesh network
- **Propagation status** — track message delivery and propagation

### 🔌 Interface Management
- **Configure interfaces** — AutoInterface, TCP, LoRa, Serial, RNode
- **Live monitoring** — per-interface bandwidth, error rates, uptime
- **Enable/disable** — hot-swap interfaces without restarting the daemon
- **Connection logs** — detailed interface event history

### 🌐 Network Explorer
- **Discover nodes** — browse announced services and propagation nodes
- **Service registry** — find available LXMF delivery, Nomad Network, etc.
- **Path tracing** — visualize routes between nodes
- **Announce management** — send custom announces for your services

### 🔔 Alerting System
- **Peer down alerts** — notify when known peers go offline
- **Quality degradation** — alert when link quality drops below threshold
- **Custom rules** — define alerting conditions via the web UI
- **Notification channels** — email, webhook, LXMF message

## Tech Stack

| Component      | Technology                          |
|---------------|--------------------------------------|
| Framework      | Ruby on Rails 8                      |
| Frontend       | Hotwire (Turbo + Stimulus)           |
| Styling        | Tailwind CSS                         |
| Database       | SQLite (production-ready with WAL)   |
| Real-time      | Action Cable (WebSocket)             |
| Background     | Solid Queue                          |
| RNS Connection | Unix socket / TCP to rnsd            |

## Quick Start

### Prerequisites

- Ruby 3.3+
- Rails 8
- Reticulum (`pip install rns`) with `rnsd` running
- SQLite 3

### Installation

```bash
git clone https://github.com/synthalorian/reticulum-hub.git
cd reticulum-hub
bin/setup
bin/rails server
```

Open http://localhost:3000 in your browser.

### Connecting to rnsd

Reticulum Hub communicates with the RNS daemon via its built-in API. Ensure `rnsd` is running:

```bash
# Install RNS
pip install rns

# Start the daemon (with the web API enabled)
rnsd --example-config > ~/.reticulum/config
# Enable the RNS shared instance API in your config
rnsd
```

## Architecture

```
┌─────────────────────────────────────────────────┐
│                   Browser                        │
│  ┌─────────┐ ┌──────────┐ ┌───────────────────┐ │
│  │Stimulus │←│  Turbo   │←│ Action Cable WS   │ │
│  │Controllers│ │ Streams  │ │ (real-time push)  │ │
│  └─────────┘ └──────────┘ └───────────────────┘ │
└───────────────────────┬─────────────────────────┘
                        │ HTTP / WebSocket
┌───────────────────────┴─────────────────────────┐
│                Rails 8 Server                    │
│  ┌────────────────────────────────────────────┐  │
│  │           Controllers & Views              │  │
│  │  Dashboard│Messages│Interfaces│Explorer     │  │
│  └───────┬───────────┬───────────┬────────────┘  │
│  ┌───────┴───────────┴───────────┴────────────┐  │
│  │            Models (ActiveRecord)            │  │
│  │  Peer│Interface│Message│Alert│Config        │  │
│  └───────────────────┬────────────────────────┘  │
│  ┌───────────────────┴────────────────────────┐  │
│  │     RnsAdapter (Service Object)            │  │
│  │  • Connection pooling to rnsd              │  │
│  │  • Event stream parsing                    │  │
│  │  • Command dispatch                        │  │
│  └───────────────────┬────────────────────────┘  │
│                    SQLite                         │
└───────────────────────┬─────────────────────────┘
                        │ Unix Socket / TCP
                  ┌─────┴─────┐
                  │   rnsd    │
                  └───────────┘
```

## Project Structure

```
reticulum-hub/
├── app/
│   ├── controllers/          # Rails controllers
│   ├── models/               # ActiveRecord models
│   ├── views/                # ERB templates
│   ├── channels/             # Action Cable channels
│   ├── javascript/           # Stimulus controllers
│   └── assets/               # CSS, images
├── config/                   # Rails configuration
├── db/                       # Migrations, schema
├── public/                   # Static assets
├── README.md
└── PLAN.md
```

## License

Apache License 2.0 — see [LICENSE](LICENSE).

## Credits

Built by **synth** (synthalorian) with **synthclaw**.
