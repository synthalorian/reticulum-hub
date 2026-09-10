# Reticulum Hub

A web dashboard for managing [Reticulum](https://reticulum.network/) mesh networks. Built with Rails 8, Hotwire, and Tailwind CSS.

![Rails](https://img.shields.io/badge/Rails-8.1-red)
![Ruby](https://img.shields.io/badge/Ruby-4.0.4-cc342d)
![License](https://img.shields.io/badge/License-MIT-blue)

## Features

- **Real-time Dashboard** — Live peer discovery, interface status, and system stats via WebSocket + polling fallback
- **LXMF Messaging** — Send and receive messages through the Reticulum network stack
- **Network Explorer** — Browse discovered nodes and their announced services
- **Interface Management** — Enable, disable, and restart Reticulum interfaces from the web UI
- **Alerting** — Configurable alert rules with severity levels and status tracking
- **Mock Mode** — Fully functional without rnsd for development and demos

## Requirements

- Ruby 4.0.4
- SQLite 3
- Node.js (for Tailwind CSS asset pipeline)
- Reticulum Network Stack (optional — mock data works without it)

## Quick Start

```bash
# Clone and setup
git clone <repo-url> reticulum-hub
cd reticulum-hub
bin/setup

# Start the server
bin/rails server
```

Visit `http://localhost:3000`

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `RNSD_HOST` | `127.0.0.1` | Reticulum daemon TCP host |
| `RNSD_PORT` | `3742` | Reticulum daemon TCP port |
| `RNSD_SOCKET` | `~/.reticulum/rnsd.sock` | Unix socket path (tried first) |
| `RAILS_MASTER_KEY` | — | Production encryption key |
| `JOB_CONCURRENCY` | `1` | Solid Queue worker processes |

## Docker

```bash
# Build
docker build -t reticulum-hub .

# Run
docker run -d -p 3000:80 \
  -e RAILS_MASTER_KEY=<your-key> \
  -v reticulum-data:/rails/storage \
  --name reticulum-hub \
  reticulum-hub
```

## Architecture

```
┌─────────────┐     WebSocket / HTTP     ┌──────────────┐
│   Browser   │ ◄──────────────────────► │  Rails App   │
│  (Hotwire)  │                          │  (Puma)      │
└─────────────┘                          └──────┬───────┘
                                                │
                     ┌──────────────────────────┼──────────┐
                     │                          │          │
                ┌────▼────┐              ┌──────▼─────┐  ┌─▼────────┐
                │ SQLite  │              │ SolidQueue │  │SolidCable│
                │ (data)  │              │ (jobs)     │  │(pub/sub) │
                └─────────┘              └────────────┘  └──────────┘
                                                │
                                          ┌─────▼─────┐
                                          │ RnsAdapter│
                                          │  (TCP/    │
                                          │   Unix)   │
                                          └─────┬─────┘
                                                │
                                          ┌─────▼─────┐
                                          │   rnsd    │
                                          │ (optional)│
                                          └───────────┘
```

## Testing

```bash
# Run the full suite
bundle exec rspec

# Run with coverage
COVERAGE=true bundle exec rspec

# Security audit
bin/brakeman
bin/bundler-audit
```

## Development

```bash
# Start with Solid Queue worker
bin/jobs

# Tailwind CSS watch
bin/rails tailwindcss:watch

# Console with RNS adapter
bin/rails console
> rns = RnsAdapter.new
> rns.connect
> rns.peers
```

## Production Checklist

- [ ] Set `RAILS_MASTER_KEY`
- [ ] Run `bin/rails db:migrate`
- [ ] Start Solid Queue: `bin/jobs`
- [ ] Configure reverse proxy (nginx/caddy)
- [ ] Set up SSL/TLS
- [ ] Configure firewall for rnsd port

## License

MIT — Made by synth 🎹🤺 with synthclaw 🎹🦞

---

## ☕ Support the Developer

If this project saved you time, solved a problem, or just made your day a little more neon, you can fuel the next one:

[![Buy Me A Coffee](https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png)](https://buymeacoffee.com/synthalorian)

## License

[Apache-2.0](LICENSE)
