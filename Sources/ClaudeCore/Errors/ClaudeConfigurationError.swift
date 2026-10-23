//
//  ClaudeConfigurationError.swift
//  ClaudeCore
//
//  Created by Gagik Muradyan on 22.10.26.
//

import Foundation

/// A failure to construct Claude API connection settings.
public enum ClaudeConfigurationError: Error {
    /// The API version contains no characters outside Foundation's whitespace and newline set.
    case emptyAPIVersion
}

extension ClaudeConfigurationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyAPIVersion:
            "Claude API version string can't be empty"
        }
    }
}
