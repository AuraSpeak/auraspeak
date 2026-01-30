# AuraSpeak

AuraSpeak is an alternative to Discord and Teamspeak. Security and openness are the main focus. The aim is to keep costs as low as possible, ensuring the project remains free once released.

Two main factors are at the forefront of this: decentralization and security through encryption.

Disclaimer: The project is not yet in alpha or beta and is far from release.

Features:
- DTLS connection for client-server communication

See the [feature roadmap](Roadmap.md) for more information.

## An overview of the individual projects:

### [Workflow](https://github.com/AuraSpeak/workflow)

Set up and manage the development environment.

### [Debug UI](https://github.com/AuraSpeak/debug-ui)

A web interface for examining packet flow. It will be further developed alongside the project to identify how each packet is routed on the server.

### [Client](https://github.com/AuraSpeak/client)

AuraSpeak desktop client. Special feature: It is highly decoupled, meaning it can be tested individually in the UI Compile or loaded in the debug UI.

### [Server](https://github.com/AuraSpeak/server)

Server code for the AuraSpeak project

### [Protocol](https://github.com/AuraSpeak/protocol)

Application-level protocol for AuraSpeak, running over UDP (DTLS).”

### [network](https://github.com/AuraSpeak/network)

Networking for Server and Client + Packet Routing

## Quickstart

For now only dev:

```bash
git clone https://github.com/AuraSpeak/workflow
make setup # Clones all repos for development
make bootstrap # bootstrap the repositories
```

## Status

Status: Pre-alpha. Expect breaking changes and rapid iteration.