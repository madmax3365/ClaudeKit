//
//  File.swift
//  ClaudeKit
//
//  Created by Gagik Muradyan on 22.10.26.
//

import Foundation

/// A failure to construct Claude API connection settings.
public enum ClaudeConfigurationError: Error {
    /// The API version contains no characters outside Foundation's whitespace and newline set.
    case emptyApiVersionString
}

extension ClaudeConfigurationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyApiVersionString:
            "Claude API version string can't be empty"
        }
    }
}
