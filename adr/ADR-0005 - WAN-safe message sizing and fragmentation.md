# ADR-0005 - WAN-safe message sizing and fragmentation

---
adr: ADR-0005

project: "AuraSpeak Networking"

status: proposed
date: 2026-02-02
---

## Context

AuraSpeak is planned to run primarily over the public internet (WAN) using DTLS over UDP (e.g., client ↔ VPS). In this environment the Path MTU is not under our control and can vary due to VPNs, tunnels, NATs, and different network links.

Large UDP datagrams can trigger IP fragmentation. Fragmented UDP packets are significantly more likely to be dropped, which reduces reliability and creates hard-to-debug delivery issues.

While DTLS can carry larger records, in practice we need a conservative, WAN-safe message size for application payloads. Anything larger must be fragmented at the application layer and reassembled on the receiver.

This ADR builds on:

- [ADR-0002](https://chatgpt.com/g/g-p-693c7487e14c8191b4c9d7e75a16480c-auraspeak/c/ADR-0002%20-%20Packet%20Header.md) for header fields (`Length`, `fragment_index`, `flags`, `msg_id`).
    
- [ADR-0003](https://chatgpt.com/g/g-p-693c7487e14c8191b4c9d7e75a16480c-auraspeak/c/ADR-0003%20-%20ack.md) for selective reliability and per-fragment ACK identification.
    
- [ADR-0004](https://chatgpt.com/g/g-p-693c7487e14c8191b4c9d7e75a16480c-auraspeak/c/ADR-0004%20-%20buffer.md) for the buffering/reassembly interface.
    

## Alternatives Considered

- **Rely on IP fragmentation:** Rejected. Unreliable over WAN; fragments are often dropped and loss is amplified.
    
- **Send large DTLS records and hope they fit:** Rejected. Still constrained by UDP/PMTU; results in fragmentation or loss.
    
- **Implement PMTUD/PLPMTUD first:** Deferred. Useful later, but initial implementation should be robust without it.
    
- **Switch to a different transport (TCP/QUIC):** Rejected for this ADR. The project targets DTLS-over-UDP and a minimal networking core.
    

## Decision

### MTU baseline

The networking layer uses a WAN-safe MTU baseline:

- `DTLS_MTU = 1200` bytes
    

This value is treated as the _maximum UDP datagram size_ the stack aims to produce to avoid IP fragmentation on typical internet paths.

### Maximum application payload per packet

A fixed maximum payload size for AuraSpeak packets is defined:

- `MAX_APP_PAYLOAD = 1000` bytes
    

This is the maximum _AuraSpeak payload_ (the bytes counted by `Length` in [ADR-0002]) that may be carried in a single packet.

The remaining space up to `DTLS_MTU` is reserved for IP/UDP headers and DTLS overhead (record headers + encryption/authentication tags). The constant is intentionally conservative.

### Fragmentation policy

- Any message larger than `MAX_APP_PAYLOAD` MUST be fragmented at the application layer.
    
- Each fragment is sent as its own AuraSpeak packet, using the same `msg_id` and a unique `fragment_index` (starting at 0).
    
- Fragment count MUST be known by the receiver. The fragment count is carried in the payload prefix of each fragment (see below).
    
- Reassembly is handled using the buffer contract from [ADR-0004].
    

### Fragment payload format

To allow reassembly without expanding the fixed header, each fragment’s payload starts with a small fragment meta header:

```
fragment_count uint16
fragment_payload bytes...
```

- `fragment_count` is repeated in every fragment (idempotent, allows late fragments to still be useful).
    
- The receiver uses `msg_id` + `fragment_index` + `fragment_count` to manage the reassembly buffer.
    

### Reliability interaction

- If a message is marked reliable via the header flag (see [ADR-0003]), then every fragment MUST be acknowledged individually using the existing ACK scheme (msg_id + fragment_index).
    
- If unreliable, fragments are best-effort and may be dropped; upper layers must tolerate missing messages.
    

## Consequences

- **Positive**
    - Robust over WAN: avoids IP fragmentation and improves delivery probability.
    - Predictable sizing: consistent limits simplify encoding/decoding and testing.
    - Works with existing design: uses `msg_id` + `fragment_index` and the buffer API.
    - Backward compatible with the fixed header: fragmentation metadata stays in payload.
        
- **Negative / trade-offs**
    - Overhead: fragmented messages include per-fragment headers and more packets.
    - State: receiver must keep reassembly buffers (see [ADR-0004] timeout/limits TBD).
    - Latency: large messages may take multiple RTTs if reliable and loss occurs.
        
- **Neutral / follow-ups**
    
    - `MAX_APP_PAYLOAD` and `DTLS_MTU` may become configurable later (e.g., per connection or per environment).
    - PMTUD/PLPMTUD can be added later to safely increase throughput on “good” paths.
    - DoS hardening must be implemented: max active buffers, max total buffered bytes, and reassembly timeouts (partially covered as TBD in [ADR-0004]).