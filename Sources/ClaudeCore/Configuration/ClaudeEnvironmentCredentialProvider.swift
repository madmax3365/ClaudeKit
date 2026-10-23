//
//  ClaudeEnvironmentCredentialProvider.swift
//  ClaudeCore
//
//  Created by Gagik Muradyan on 22.10.26.
//  Copyright © 2026 Gagik Muradyan. All rights reserved.
//

import Foundation

/// A credential provider that reads the API key from an environment variable.
///
/// The environment is captured at construction, so later changes to the process
/// environment are not observed. Lookup happens on each ``apiKey()`` call, so a
/// missing or blank variable is reported when a key is requested.
public struct ClaudeEnvironmentCredentialProvider: ClaudeCredentialProviding {
    /// The name of the variable holding the API key.
    public let variableName: String
    private let environment: [String: String]

    /// Creates a provider that reads the named variable from the given environment.
    ///
    /// - Parameters:
    ///   - variableName: The variable name. Defaults to ``defaultVariableName``.
    ///   - environment: The variables to search. Defaults to the current process environment.
    /// - Throws: ``ClaudeCredentialProviderError/emptyEnvironmentVariableName`` when the
    ///   name is empty after trimming Foundation's whitespace and newline character set.
    public init(
        variableName: String = ClaudeEnvironmentCredentialProvider.defaultVariableName,
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) throws {
        guard !variableName.isWhitespaceOrEmpty else {
            throw ClaudeCredentialProviderError.emptyEnvironmentVariableName
        }
        self.variableName = variableName
        self.environment = environment
    }

    /// Returns the value of ``variableName``.
    ///
    /// - Throws: ``ClaudeCredentialProviderError/missingEnvironmentVariable(name:)`` when
    ///   the variable is not set, or ``ClaudeCredentialProviderError/emptyAPIKey`` when
    ///   its value is blank.
    public func apiKey() async throws -> String {
        guard let key = environment[variableName] else {
            throw ClaudeCredentialProviderError.missingEnvironmentVariable(
                name: variableName
            )
        }

        guard !key.isWhitespaceOrEmpty else {
            throw ClaudeCredentialProviderError.emptyAPIKey
        }

        return key
    }
}

// MARK: - Defaults
extension ClaudeEnvironmentCredentialProvider {
    /// The conventional Anthropic API key variable, `ANTHROPIC_API_KEY`.
    public static let defaultVariableName: String = "ANTHROPIC_API_KEY"
}

// MARK: - Redaction
extension ClaudeEnvironmentCredentialProvider: CustomStringConvertible,
    CustomDebugStringConvertible, CustomReflectable
{
    public var description: String {
        "ClaudeEnvironmentCredentialProvider(variableName: \(variableName))"
    }

    public var debugDescription: String {
        description
    }

    public var customMirror: Mirror {
        Mirror(self, children: ["variableName": variableName])
    }
}
