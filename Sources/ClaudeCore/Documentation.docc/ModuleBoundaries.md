# Module Boundaries

Keep infrastructure reusable while making dependency direction and API visibility explicit.

## Overview

Modules depend on the lower-level services they use. Core never depends on endpoint, tool, MCP, or agent modules. Planned modules describe responsibility boundaries, not a requirement to create every target immediately.

## Module responsibilities

| Module | Owns | Does not own |
| --- | --- | --- |
| ClaudeCore | HTTP, configuration, credentials, transport, response metadata, reliability, generic SSE and serialization, HTTP API errors | Messages models, tool execution, MCP semantics, agent state |
| ClaudeKit | High-level API client, endpoint models, Messages and endpoint-specific streaming events | Network transport implementation, agent orchestration |
| ClaudeTools | Tool registration, typed handlers, execution loops, and tool policies | Generic HTTP transport |
| ClaudeMCP | MCP protocol client and Claude integration | Agent session ownership |
| ClaudeAgents | Orchestration, sessions, state management, and observability | Low-level HTTP and SSE parsing |
| ClaudeCLI | Executable playground that exercises SDK public APIs | Reusable SDK implementation |

The current executable is named ClaudeCLI. ClaudeKitCLI is a proposed name, not an existing target.

## Dependency direction

The intended conceptual graph is:

```text
ClaudeAgents -> ClaudeTools / ClaudeMCP -> ClaudeKit -> ClaudeCore
ClaudeCLI -> ClaudeKit
```

Each arrow means the module on the left may depend on the module on the right. A higher-level module may also declare a direct dependency on a lower-level module when it actually imports that module. Avoid speculative dependency edges and cycles.

Core may understand Anthropic HTTP conventions. That does not permit it to import ClaudeKit models or interpret Messages content and tool-use semantics. Test targets depend on the modules they test; production targets never depend on tests.

SwiftPM target dependencies must explicitly reflect imports. A package product describes what consumers can select, while a target defines a module and its dependencies; these are separate design decisions.

## Access-control policy

Use the narrowest access level that serves the intended caller:

| Access | Intended use |
| --- | --- |
| private / fileprivate | Details local to a declaration or file |
| internal | Default for implementation details used within a module |
| package | Contracts shared across this package's modules without exposing them to external consumers |
| public | Deliberate, documented consumer API and supported extension points |

Do not make a declaration public merely because another target in this package needs it. Conversely, a type appearing in a public signature must have sufficient visibility; package access cannot hide a type required by a public consumer contract.

Public initializers and protocol requirements need deliberate review as well as public type declarations. Public APIs are compatibility commitments. Keep concrete transport details and implementation helpers internal unless a documented use case requires broader access.

## Consumer imports and API exposure

Core owns its public infrastructure types. Consumers explicitly import ClaudeCore when using those types, such as configuration, credentials, errors, or custom transport contracts. Ordinary endpoint usage imports ClaudeKit. ClaudeKit initially provides no Core typealiases or module re-exports.

External custom transports are a supported extension point. The transport protocol and types exposed by its public requirements must be public, with sufficient public construction and inspection APIs for an external implementation. Concrete signatures will be designed during the HTTP foundation tasks.

Only deliberate consumer contracts are public. Helpers shared between package modules remain package-accessible, and module implementation details remain internal or more restricted. Supporting external transport implementations does not require making the internal HTTP coordinator public.

Explicit imports make ownership clear and avoid committing to aliases or exposing Core's entire namespace through ClaudeKit. Revisit convenience aliases only when real usage demonstrates a need.

A separate ClaudeCore library product is a distinct packaging choice if independent Core consumption is needed. This policy does not add one. Validate the intended imports and custom transport conformance from an external consumer package when those public APIs exist.

## Current manifest status

The package declares ClaudeCore, ClaudeKit, ClaudeCLI, ClaudeKitTests, and ClaudeCoreTests. It exposes a ClaudeKit library product and ClaudeCLI executable product.

The existing production targets now match the intended dependency direction:

```text
ClaudeCLI -> ClaudeKit -> ClaudeCore
```

Core has no higher-level dependencies. Each test target depends on its corresponding library module, and both test targets have source files. ClaudeCoreTests covers configuration and credential providers; ClaudeKitTests still contains only an empty placeholder test.

Xcode successfully built the project, including test targets, during the manifest review. This verifies compilation for the selected Xcode configuration, not test execution, Linux compatibility, or documentation generation.

Core has no separate library product. Consumer imports follow the explicit-import policy above; independent Core product distribution is not required by this decision. Package-wide default MainActor isolation has been removed, as described in <doc:Architecture>.

The maintainer confirmed that DocC preview works as expected. The dependency boundaries, isolation policy, and API exposure strategy are now recorded. Future public APIs still require external-consumer validation as they are implemented.

## Documentation validation

From the package root, generate documentation for Core:

```sh
swift package generate-documentation --target ClaudeCore
```

Preview that target locally:

```sh
swift package --disable-sandbox preview-documentation --target ClaudeCore
```

The preview command follows the DocC plugin's documented local-server workflow. Stop the preview server when finished. Resolve package-loading or compilation failures before interpreting documentation output.

CORE-003 is complete only after the architecture decisions are recorded, target dependencies match the agreed boundaries, documentation generation succeeds, and the rendered landing page and both articles have been inspected. Check that topic navigation and symbol links resolve and that no template placeholders remain.

## References

- [Swift access control](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/accesscontrol/)
- [Swift Package Manager](https://docs.swift.org/package-manager/)
- [Swift-DocC](https://github.com/swiftlang/swift-docc)
- [Swift-DocC Plugin](https://github.com/swiftlang/swift-docc-plugin)
