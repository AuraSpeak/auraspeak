# ADR-0003: Reliable delivery and ACKs

adr: ADR-0003

project: "AuraSpeak Networking"

status: proposed

date: 2026-01-31
---

## Context

Many, but not all, packets – for example, audio or video packets – prioritise delay over quality, but even here it should be possible to explicitly set reliability. UPD is a stateless transport protocol. This means items are sent but not checked to see if they are received. A separate implementation of ACKs, similar to TCP, is required.

## Alternatives Considered

- **TCP for reliable, UPD for unreliable:** Rejected to keep a single transport and a unified packet format; mixing two transports would complicate the shared networking layer (ADR-0001).
- **No ACKs, best-effort only:** Rejected because some messages must be guaranteed delivered; upper layers need clear success or failure.
- **External library (e.g. QUIC, ENet):** Rejected for this decision; the protocol stays minimal and under full control; such options could be revisited later.

## Decision

A reliable flag is set in the header (ADR-0002) to filter which messages require an ACK. The reliable flag must be implemented for this.

ACK packets are identified by a dedicated `PacketType` value (to be assigned in the protocol spec). The message ID of the sent message is sent back in the payload of an ACK packet. Fragmented messages are sent back with msg_id + "," + fragment_index.

If no acknowledgement is received after time X, the message must be resent. The value of X is TBD and will be defined in a follow-up ADR or in the implementation spec; it should be chosen based on expected RTT and environment.

The encoded message is stored in the flight buffer until the ACK for the message_id returns. After three failed attempts, the message is categorically marked as undeliverable and an error is thrown.

Reliability guarantees delivery only, not ordering: messages may be delivered out of order. Receiving the same ACK multiple times (e.g. due to retransmission) is idempotent and does not change sender state beyond the first acceptance.

## Consequences

- **Positive**
  - Selective reliability: Only packets with the reliable flag incur ACK overhead; delay-sensitive traffic (e.g. audio/video) can stay unacknowledged.
  - Clear failure semantics: After three failed attempts, the message is marked undeliverable and an error is thrown, giving predictable behavior for upper layers.
  - Flight buffer keeps unacked messages until ACK or failure, so retransmission can use the same encoded payload.
  - ACK payload format (msg_id, optionally msg_id + "," + fragment_index) supports both whole messages and fragments and aligns with the header’s fragment_index.

- **Negative / trade-offs**
  - Flight buffer size can grow with many in-flight reliable messages; memory and/or rate limiting may be needed.
  - Timeout X is TBD: too short causes unnecessary retries and extra load; too long delays failure detection and user-visible errors.
  - Fixed “three retries” policy may not fit all latency or reliability requirements; tuning or configuration might be needed later.
  - ACK traffic adds overhead; under packet loss or high load this can increase congestion and latency.
  - Implementation complexity: sender must maintain state, timers, and retry logic; receiver must generate and send ACKs for every reliable packet.

- **Neutral**
  - Relies on the header from ADR-0002: the reliable flag lives in the existing `flags` byte, so no header layout change is required.
  - Fragmented reliable messages require per-fragment ACKs (msg_id + fragment_index), consistent with the fragment_index field in the header.
