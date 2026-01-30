# AuraSpeak Roadmap

Roadmap for solo development; order and scope may change. Open Source: early milestones (up to ~0.0.4) are contributor-friendly (clear repos, small tasks).

## How to read this

**Phase 1** is foundation and first features (Pre-Alpha through 0.0.4); **Phase 2** is scale, auth, structure, and polish (0.0.5–0.0.8). Components (Protocol, Network, Server, Client, Platform, etc.) are described in [Architecture](docs/architecture.md). **Status** per milestone: `planned` | `in progress` | `done`.

---

## Phase 1 – Foundation and first features

### Pre-Alpha – Transport & framing basics

**Status:** planned  
**Goal:** Reliable framing and transport basics.

- [Protocol] Simple header format
- [Protocol, Network] Ack for reliable packets
- [Network] Fragmentation

### 0.0.1 – Sending Text

**Status:** planned  
**Goal:** Persist and send text (one-shot and long).

- [Server] Add SQLite
- [Server, Client, Network, Protocol] Text messages (one-shot and long)
- [Network] Router: catch unimplemented packets

### 0.0.2 – First Packets

**Status:** planned  
**Goal:** Channels, client UI, and packet routing for new types.

- [Server, Client, Network, Protocol] Channels
- [Client] Client UI (MVP)
- [Server, Network] Packet routing for new packet types

### 0.0.3 – File Upload

**Status:** planned  
**Goal:** Basic file upload with protocol and reliable delivery.

- [Client, Server, Protocol, Network] File upload (basic version)
- [Protocol] FileOffer/FileAccept/FileChunk/FileAck
- [Network] Reliable delivery

### 0.0.4 – Voice

**Status:** planned  
**Goal:** Send and receive voice frames; server forward; client capture/playback.

- [Client, Server, Protocol, Network] Send/receive voice frames
- [Protocol] VoiceFrame/VoiceState
- [Server] Forward
- [Client] Capture/playback

---

## First usable server

After 0.0.4 you have a first usable server (foundation + text, channels, file upload, voice).

---

## Phase 2 – Scale, auth, structure, polish

### 0.0.5 – Bring it in shape

**Status:** planned  
**Goal:** Multiplexer and stream framing for scaling.

- [Network] Multiplexer (multiple logical streams over one DTLS connection)
- [Protocol] Stream IDs/framing if needed

### 0.0.6 – Auth

**Status:** planned  
**Goal:** Platform repo, auth (login, token), identity/keys.

- [Platform, Workflow] Create and wire in platform repo
- [Server, Client] Auth (login, token)
- [Platform] Identity/keys

### 0.0.7 – Server Structure

**Status:** planned  
**Goal:** Tags, channel capabilities, permission system.

- [Server] Tags (channel categories)
- [Server] Channel capabilities (what a channel can do, e.g. text only / voice only)
- [Server] Permission system (roles/permissions per user)

### 0.0.8 – Polish

**Status:** planned  
**Goal:** Performance hotspots, refactors/ADRs, UI polish.

- [Server, Client, Network] Identify hotspots (performance)
- [Workflow] Better solutions/refactors/ADRs
- [Client] Polish UI
