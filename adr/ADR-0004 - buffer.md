# ADR-0004: buffer

adr: ADR-0004

project: "AuraSpeak Networking"

status: proposed

date: 2026-02-02
---

## Context
Within the shared networking layer ([ADR-0001](ADR-0001%20-%20Networking%20Repo.md)), enabling fragmentation requires buffers. Blobs that exceed the maximum payload size (see [ADR-0002](ADR-0002%20-%20Packet%20Header.md)) can be split before sending and reassembled on the receiver; fragment identification aligns with the ACK format in [ADR-0003](ADR-0003%20-%20ack.md) (msg_id + fragment_index).

## Decision

A general interface is defined that will be implemented by all blob types. Buffer instances are created via constructors outside the interface (e.g. `NewFragmentBuffer(msgID, countFragments)`), which return the concrete type; the interface describes only the behaviour of an existing buffer:

```go
type Buffer interface {
	Add(fragmentIndex uint16, content []byte) error
	Done() bool
	Reassemble() ([]byte, error)
}

type FragmentBuffer struct {
	messageID     uint32
	countFragments uint16
	// ... internal fragment storage
}

func NewFragmentBuffer(msgID uint32, countFragments uint16) *FragmentBuffer
```

- **Add** adds a fragment to the buffer. It may be called in any order. Duplicate `fragment_index` are treated idempotently (overwrite or ignore).
- **Done** returns true when all expected fragments have been received; **Reassemble** is only valid when Done is true.
- **Reassemble** builds the complete payload and returns it. After a successful call, the buffer is considered consumed; further calls to Add or Reassemble are invalid (implementation may panic or return error). Buffer reuse is not part of this contract.
- Timeout (discard incomplete buffers after T) and maximum number of active buffers per connection are TBD and can be defined in the implementation spec or a follow-up ADR.

## Consequences

- **Positive**
  - Unified interface: all blob types use the same buffer API; fragmentation and reassembly stay consistent.
  - Clear lifecycle: constructor → Add → Done → Reassemble simplifies implementation and usage.
  - Early completeness check: Done allows checking whether the buffer is full without calling Reassemble.
  - Separation of concerns: reassembled data can be stored and distributed according to application logic; buffer logic stays independent of upper layers.
  - Enables messages that exceed the maximum payload size (e.g. the 64 KiB cap from [ADR-0002](ADR-0002%20-%20Packet%20Header.md)).

- **Negative / trade-offs**
  - Buffers hold memory until reassembly is complete; with many concurrent fragmented messages, memory use can grow (limits via max active buffers and timeout are TBD).
  - Each blob type implements this interface; duplicate, ordering, and error cases are specified in the contract but add implementation effort.
  - Go convention: the constructor lives outside the interface; different blob types have their own constructors (e.g. NewFragmentBuffer).

- **Neutral**
  - Builds on [ADR-0002](ADR-0002%20-%20Packet%20Header.md) (`fragment_index` in the header) and uses the fragment identification (msg_id + fragment_index) from [ADR-0003](ADR-0003%20-%20ack.md).
  - Additional blob types can implement the same interface without changing the overall design.
