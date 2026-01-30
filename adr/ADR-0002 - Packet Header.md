# ADR-0002 - Packet Header

adr: ADR-0002

project: "AuraSpeak Networking"

status: Accepted

date: 2026-01-30
---

## Context

The shared networking layer (see [ADR-0001](ADR-0001%20-%20Networking%20Repo.md)) needs a fixed header for routing, identification, and handling of packets. For now the header is kept simple and will grow as control and transport functionalities are implemented. At the time of this document it is minimal; later ADRs may introduce additional header fields.

## Decision

A fixed 12-byte "generic" header is used so that new fields can be added later without much re-evaluation. Byte order is network byte order (big-endian).

```
magic uint8
ProtocolVersion uint8
PacketType uint8
flags uint8
msg_id uint32
Length uint16
fragment_index uint16
```

- **magic:** If invalid, the packet is dropped immediately.
- **ProtocolVersion:** Used to check whether the peer can handle this protocol version.
- **PacketType:** The packet type; required for routing and handling.
- **flags:** Additional information on how the packet should be handled.
- **Length:** Payload length in bytes.
- **fragment_index:** Primarily for indexing fragments; when not used for fragmentation, it may be reused for other purposes (to be specified in later ADRs if needed).

## Consequences

- **Positive**
  - Fixed header layout gives predictable parsing, clear byte order, and low overhead.
  - The design is extensible: new fields can be added in later ADRs without breaking the basic format.
  - Magic byte and protocol version allow early rejection of invalid or incompatible packets (e.g. wrong magic → drop immediately).
  - `PacketType` and `flags` separate routing and handling from payload content.

- **Negative / trade-offs**
  - Fixed field sizes (e.g. `Length` as uint16) cap maximum payload size (e.g. 64 KiB); larger messages rely on fragmentation or future changes.
  - `fragment_index` is described as reusable for other purposes when not used for fragmentation, which can lead to different interpretations across implementations unless specified elsewhere.

- **Neutral**
  - Header size is fixed (e.g. 12 bytes), which simplifies buffering and alignment.
  - Any future header extension may affect backward compatibility; the version field supports explicit protocol-version checks for that.
