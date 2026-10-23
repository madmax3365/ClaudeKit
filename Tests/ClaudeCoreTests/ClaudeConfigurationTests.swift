//
//  ClaudeConfigurationTests.swift
//  ClaudeCoreTests
//
//  Created by Gagik Muradyan on 22.10.26.
//

import ClaudeCore
import Foundation
import Testing

struct ClaudeConfigurationTests {
    @Test(
        "Initializes correctly with or without supplied arguments and respects default args",
        arguments: [
            (URL(string: "https://example.com"), "some-api-version"),
            (URL(string: "https://example.com"), nil),
            (nil, "some-api-version"),
            (nil, nil),
        ]
    )
    func initialize(baseURL: URL?, apiVersion: String?) throws {
        // Given
        let expectedURL = baseURL ?? ClaudeConfiguration.defaultBaseURL
        let expectedAPIVersion =
            apiVersion ?? ClaudeConfiguration.defaultAPIVersion
        let sut: ClaudeConfiguration

        // When
        if let baseURL, let apiVersion {
            sut = try ClaudeConfiguration(
                baseURL: baseURL,
                apiVersion: apiVersion
            )
        } else if let baseURL {
            sut = try ClaudeConfiguration(baseURL: baseURL)
        } else if let apiVersion {
            sut = try ClaudeConfiguration(apiVersion: apiVersion)
        } else {
            sut = try ClaudeConfiguration()
        }

        // Then
        #expect(sut.baseURL == expectedURL)
        #expect(sut.apiVersion == expectedAPIVersion)
    }

    @Test(
        "Throws an error when invalid configuration is supplied",
        arguments: ["", "   ", "\n", "\t", " \n\t "]
    )
    func throwsErrorOnInvalidConfiguration(apiVersion: String) throws {
        #expect(throws: ClaudeConfigurationError.emptyAPIVersion) {
            _ = try ClaudeConfiguration(apiVersion: apiVersion)
        }
    }
}
