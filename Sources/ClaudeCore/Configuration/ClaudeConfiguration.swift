//
//  ClaudeConfiguration.swift
//  ClaudeCore
//
//  Created by Gagik Muradyan on 22.10.26.
//

import Foundation

/// Connection settings for Claude API requests, independent of credentials and transport.
///
/// Configuration preserves supplied values and performs no network access. Construction
/// rejects blank API versions but does not validate server support or URL suitability.
public struct ClaudeConfiguration: Sendable, Equatable {
    /// The server root used for endpoint requests, normally without the `/v1` prefix.
    ///
    /// Custom URLs, including proxy path prefixes, are stored unchanged. Request-path
    /// composition belongs to the request builder, not this value type.
    public let baseURL: URL
    /// The value intended for the `anthropic-version` header, not a model identifier.
    ///
    /// Nonblank values are preserved verbatim, including surrounding whitespace.
    /// Acceptance here does not imply a supported API version or a valid HTTP header value.
    public let apiVersion: String

    /// Creates connection settings with optional overrides for the SDK defaults.
    ///
    /// - Parameters:
    ///   - baseURL: The server root. Defaults to ``defaultBaseURL``.
    ///   - apiVersion: The HTTP API version. Defaults to `2026-10-21`.
    /// - Throws: ``ClaudeConfigurationError/emptyAPIVersion`` when the version
    ///   is empty after trimming Foundation's whitespace and newline character set.
    public init(
        baseURL: URL = ClaudeConfiguration.defaultBaseURL,
        apiVersion: String = ClaudeConfiguration.defaultAPIVersion
    ) throws {
        guard !apiVersion.isWhitespaceOrEmpty else {
            throw ClaudeConfigurationError.emptyAPIVersion
        }
        
        self.baseURL = baseURL
        self.apiVersion = apiVersion
    }

}

// MARK: - Defaults
extension ClaudeConfiguration {
    /// The Anthropic API server root, `https://api.anthropic.com`.
    public static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.anthropic.com") else {
            preconditionFailure("Invalid default Claude API URL")
        }
        return url
    }()

    /// The SDK's default HTTP API version, `2026-10-21`.
    ///
    /// This value is pinned by the SDK; it does not automatically track server releases.
    public static let defaultAPIVersion: String = "2026-10-21"
}
