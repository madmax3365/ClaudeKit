//
//  ClaudeStaticCredentialProvider.swift
//  ClaudeCore
//
//  Created by Gagik Muradyan on 22.10.26.
//

import Foundation

/// A credential provider that returns a fixed API key supplied at construction.
///
/// The key is never included in the provider's description, debug description,
/// or reflected mirror.
public struct ClaudeStaticCredentialProvider: ClaudeCredentialProviding {
    private let key: String

    /// Creates a provider that always returns the supplied key.
    ///
    /// - Parameter apiKey: The API key. Nonblank values are preserved verbatim.
    /// - Throws: ``ClaudeCredentialProviderError/emptyAPIKey`` when the key is empty
    ///   after trimming Foundation's whitespace and newline character set.
    public init(apiKey: String) throws {
        guard !apiKey.isWhitespaceOrEmpty else {
            throw ClaudeCredentialProviderError.emptyAPIKey
        }
        self.key = apiKey
    }

    public func apiKey() async throws -> String {
        key
    }
}

// MARK: - Redaction
extension ClaudeStaticCredentialProvider: CustomStringConvertible,
    CustomDebugStringConvertible, CustomReflectable
{
    public var description: String {
        "ClaudeStaticCredentialProvider(apiKey: <redacted>)"
    }

    public var debugDescription: String {
        description
    }

    public var customMirror: Mirror {
        Mirror(self, children: ["apiKey": "<redacted>"])
    }
}
