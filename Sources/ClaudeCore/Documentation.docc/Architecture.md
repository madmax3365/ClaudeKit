# Core Architecture

Define the infrastructure contracts that keep networking independent of Claude endpoint semantics.

## Overview

ClaudeCore provides the low-level foundation for the SDK. The design favors small value types, explicit dependencies, Swift 6 concurrency checking, and Foundation networking. Introduce additional abstractions only when a concrete responsibility or testing requirement justifies them.

These are design policies for upcoming implementation work. They do not specify final method signatures or promise that the described services already exist.

## HTTP transport and dependency injection

The transport abstraction belongs to Core. It accepts a Core HTTP request representation and returns a Core HTTP response representation; streaming support will expose bytes and response metadata without interpreting Messages events.

A Foundation URLSession implementation will provide the default network transport. Code that coordinates HTTP requests receives its transport as a dependency rather than constructing a hidden session or relying on a global singleton. Tests can supply a deterministic transport that records requests and returns responses or failures without accessing the network.

Keep responsibilities separate:

- Request construction applies configuration, credentials, and Anthropic HTTP headers.
- Transport performs network I/O and exposes HTTP status, headers, and body data.
- Core HTTP coordination interprets unsuccessful responses and applies reliability policies.
- ClaudeKit constructs endpoint payloads and interprets successful endpoint responses.

An HTTP error status is still a received HTTP response. A connection failure is a transport failure. Preserve that distinction so response metadata and error bodies remain available to the layer that owns their interpretation.

External consumers may implement custom transports. The transport protocol and every type exposed by its public requirements must be public, with the construction and inspection APIs an external implementation needs. Consumers explicitly import ClaudeCore to use these contracts. Internal dependency injection remains required; see <doc:ModuleBoundaries> for the API exposure policy.

## Configuration and credentials

Core owns connection configuration and credential-provider contracts. Credential lookup should remain separate from request construction so callers and tests can choose how credentials are supplied.

Do not embed credentials in source code or expose them through request descriptions, diagnostics, or logging. Configuration and credential-provider APIs will be specified in their implementation tasks; this article does not freeze their shape.

## Concurrency and isolation

Favor value types and Sendable contracts for values that cross isolation boundaries. Use structured concurrency and propagate cancellation through request execution and streaming. Avoid unstructured tasks that outlive the operation without an explicit lifecycle owner.

Use actors when shared mutable state requires isolation, such as coordinated rate-limit state. Stateless services do not need actors by default. Networking contracts should not require a caller to execute on the main actor merely to use the SDK.

The package does not apply default MainActor isolation to its targets. Add explicit actor isolation where a concrete responsibility requires it. Strict concurrency checking and default main-actor isolation are separate choices.

## Serialization and endpoint decoding

Core owns general-purpose representation and framing: flexible JSON values, JSON encoding and decoding infrastructure, multipart encoding, binary payload handling, and JSONL framing. A generic decoder may operate on a caller-supplied Decodable type without knowing its endpoint meaning.

ClaudeKit owns concrete endpoint request and response models, including Messages content blocks and tool-use payloads. It chooses which domain model to decode and validates endpoint-specific semantics. Core must not import those models or switch on their cases.

For example, Core may decode an Anthropic HTTP error envelope because HTTP failure handling is its responsibility. It must not decode a successful Messages response into a Messages-specific type defined inside Core.

## Streaming boundary

Core owns byte delivery and incremental server-sent event framing. Its parser must tolerate input boundaries that split text or events and represent generic SSE fields without assuming Claude message semantics.

ClaudeKit maps generic SSE events into endpoint-specific events, decodes their payloads, and interprets message lifecycle rules. An error event received inside a successful HTTP stream is interpreted by the endpoint layer; Core's SSE parser only frames it.

Stream cancellation, completion, and transport failures must propagate predictably. Detailed buffering, backpressure, and AsyncSequence contracts belong to the streaming milestone.

## Error ownership

Assign errors to the layer that understands their meaning:

| Layer | Responsibility |
| --- | --- |
| ClaudeCore | Transport failures, HTTP failure metadata, Anthropic HTTP error envelopes, and generic serialization or SSE framing failures |
| ClaudeKit | Endpoint decoding context, unsupported or invalid domain content, and endpoint-specific streaming failures |
| ClaudeTools / ClaudeMCP | Tool execution and MCP protocol failures respectively |
| ClaudeAgents | Orchestration and session failures |

Preserve useful underlying causes and response metadata when adding context. Do not turn cancellation into an API rejection or a retryable network failure. Error reporting must not disclose credentials or unredacted sensitive payloads.

Higher layers may translate an error into a more meaningful domain failure, but Core must never depend on higher-level error types. The concrete error taxonomy remains part of the API errors task.

## Reliability policy

Retries, backoff, jitter, Retry-After handling, timeouts, and rate limits belong in Core's HTTP coordination layer. Transport implementations should not silently add their own SDK retry loops.

A retry decision must account for cancellation, request replay safety, and available response metadata. Detailed defaults and replay rules will be designed in the reliability milestone; this document does not promise automatic retries for every failed request.

## Implementation and validation

Implement these contracts through the planned HTTP foundation, reliability, streaming, serialization, and hardening milestones. Do not create future modules solely to satisfy this conceptual design.

When implementations exist, verify the boundaries with scenarios such as:

- A fake transport captures a built request without network access.
- An HTTP error response retains its status and useful metadata.
- A transport failure remains distinguishable from an API rejection.
- Cancellation terminates an operation without scheduling another retry.
- Generic SSE framing works without importing Messages models.
- Endpoint decoding remains in ClaudeKit even when generic decoding helpers live in Core.

## References

- [Anthropic API overview](https://platform.claude.com/docs/en/api/overview)
- [Anthropic HTTP API](https://platform.claude.com/docs/en/api/http)
- [Anthropic errors](https://platform.claude.com/docs/en/api/errors)
- [Anthropic API versioning](https://platform.claude.com/docs/en/api/versioning)
- [Anthropic streaming](https://platform.claude.com/docs/en/build-with-claude/streaming)

Consult the current specifications when implementing wire formats and headers. This architecture intentionally does not pin an API version or enumerate current endpoint schemas.
