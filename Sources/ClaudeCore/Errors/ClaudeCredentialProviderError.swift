//
//  ClaudeCredentialProviderError.swift
//  ClaudeCore
//
//  Created by Gagik Muradyan on 22.10.26.
//  Copyright © 2026 Gagik Muradyan. All rights reserved.
//

import Foundation

/// A failure to construct a credential provider or obtain an API key from it.
public enum ClaudeCredentialProviderError: Error, Equatable {
    /// The API key contains no characters outside Foundation's whitespace and newline set.
    case emptyAPIKey
    /// The named environment variable is not set.
    case missingEnvironmentVariable(name: String)
    /// The environment variable name contains no characters outside Foundation's
    /// whitespace and newline set.
    case emptyEnvironmentVariableName
}

extension ClaudeCredentialProviderError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyAPIKey:
            "Claude API key can't be empty"
        case .missingEnvironmentVariable(let name):
            "Environment variable \(name) is not set"
        case .emptyEnvironmentVariableName:
            "Environment variable name for Claude API key can't be empty"
        }
    }
}
