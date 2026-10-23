//
//  ClaudeCredentialProviding.swift
//  ClaudeCore
//
//  Created by Gagik Muradyan on 22.10.26.
//

import Foundation

/// A source of the API key used to authenticate Claude API requests.
///
/// Providers are queried per request, so implementations may rotate, refresh, or
/// fetch keys lazily. Conforming types must not expose the key through descriptions,
/// diagnostics, or logging.
public protocol ClaudeCredentialProviding: Sendable {
    /// Returns the API key to send with the next request.
    ///
    /// - Throws: An error when no usable key is available.
    func apiKey() async throws -> String
}
