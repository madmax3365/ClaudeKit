# ``ClaudeCore``

The HTTP, serialization, and streaming foundation for the ClaudeKit SDK.

## Overview

ClaudeCore defines the infrastructure boundary between higher-level Claude API clients and network communication. It owns HTTP primitives, configuration, credential handling, transport, response metadata, and API error envelopes. Its planned responsibilities also include retries, rate limits, incremental server-sent event parsing, and general-purpose serialization.

Core may understand Anthropic-specific HTTP conventions, including authentication and API version headers. Endpoint models, Messages content blocks, tool-use semantics, message-specific streaming events, and agent state belong in higher-level modules.

> Important: This catalog documents the intended architecture. Core currently provides a configuration value, credential providers, and their construction errors. The remaining infrastructure is scaffolding, not a working HTTP client. Documentation of a responsibility does not imply that its implementation is available.

Read <doc:Architecture> for the transport, concurrency, serialization, and error design. Read <doc:ModuleBoundaries> for dependency direction, access control, and the explicit Core import policy.

## Topics

### Configuration

- ``ClaudeConfiguration``
- ``ClaudeConfigurationError``

### Credentials

- ``ClaudeCredentialProviding``
- ``ClaudeStaticCredentialProvider``
- ``ClaudeEnvironmentCredentialProvider``
- ``ClaudeCredentialProviderError``

### Architecture

- <doc:Architecture>
- <doc:ModuleBoundaries>
