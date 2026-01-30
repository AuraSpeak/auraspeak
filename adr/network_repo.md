# ADR-0001 - Networking Repo

adr: ADR-0001

project: "AuraSpeak Networking"

status: Accepted

date: 2026-01-30
---

## Context

It is possible to combine many parts of the net code for the client and server. Furthermore, it appears that many parts, such as buffers, the router, and the fragmentation logic, are the same in both the client and server.

## Decision

A repository will be created that combines the net code from the client and server. Everything implemented on the server and client in the same or a similar way will be united in this repository.

## Consequences

- Create a repo (network).
- Move the net code from the server and client to the repo.
- The structure must be adjusted.
- Adapt the client and server to the new repository.