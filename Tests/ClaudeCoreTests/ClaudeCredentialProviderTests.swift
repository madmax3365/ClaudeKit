//
//  ClaudeCredentialProviderTests.swift
//  ClaudeCoreTests
//
//  Created by Gagik Muradyan on 23.10.26.
//  Copyright © 2026 Gagik Muradyan. All rights reserved.
//

import ClaudeCore
import Foundation
import Testing

struct ClaudeStaticCredentialProviderTests {
    @Test("Returns the supplied API key")
    func returnsKey() async throws {
        // Given
        let sut = try ClaudeStaticCredentialProvider(apiKey: "sk-test-key")

        // When
        let key = try await sut.apiKey()

        // Then
        #expect(key == "sk-test-key")
    }

    @Test(
        "Throws an error when a blank API key is supplied",
        arguments: ["", "   ", "\n", "\t", " \n\t "]
    )
    func throwsOnBlankKey(apiKey: String) {
        #expect(throws: ClaudeCredentialProviderError.emptyAPIKey) {
            _ = try ClaudeStaticCredentialProvider(apiKey: apiKey)
        }
    }

    @Test("Redacts the API key from descriptions and reflection")
    func redactsKey() throws {
        // Given
        let sut = try ClaudeStaticCredentialProvider(apiKey: "sk-test-key")
        var dumped = ""

        // When
        dump(sut, to: &dumped)

        // Then
        #expect(!String(describing: sut).contains("sk-test-key"))
        #expect(!String(reflecting: sut).contains("sk-test-key"))
        #expect(!dumped.contains("sk-test-key"))
    }
}

struct ClaudeEnvironmentCredentialProviderTests {
    @Test("Returns the API key from the named variable")
    func returnsKey() async throws {
        // Given
        let sut = try ClaudeEnvironmentCredentialProvider(
            variableName: "CUSTOM_KEY",
            environment: ["CUSTOM_KEY": "sk-test-key"]
        )

        // When
        let key = try await sut.apiKey()

        // Then
        #expect(key == "sk-test-key")
    }

    @Test("Uses ANTHROPIC_API_KEY by default")
    func usesDefaultVariableName() async throws {
        // Given
        let sut = try ClaudeEnvironmentCredentialProvider(
            environment: ["ANTHROPIC_API_KEY": "sk-test-key"]
        )

        // When
        let key = try await sut.apiKey()

        // Then
        #expect(sut.variableName == "ANTHROPIC_API_KEY")
        #expect(key == "sk-test-key")
    }

    @Test("Throws an error when the variable is not set")
    func throwsOnMissingVariable() async throws {
        // Given
        let sut = try ClaudeEnvironmentCredentialProvider(
            variableName: "CUSTOM_KEY",
            environment: [:]
        )

        // Then
        await #expect(
            throws: ClaudeCredentialProviderError.missingEnvironmentVariable(
                name: "CUSTOM_KEY"
            )
        ) {
            _ = try await sut.apiKey()
        }
    }

    @Test(
        "Throws an error when the variable value is blank",
        arguments: ["", "   ", "\n", "\t", " \n\t "]
    )
    func throwsOnBlankValue(value: String) async throws {
        // Given
        let sut = try ClaudeEnvironmentCredentialProvider(
            variableName: "CUSTOM_KEY",
            environment: ["CUSTOM_KEY": value]
        )

        // Then
        await #expect(throws: ClaudeCredentialProviderError.emptyAPIKey) {
            _ = try await sut.apiKey()
        }
    }

    @Test(
        "Throws an error when a blank variable name is supplied",
        arguments: ["", "   ", "\n", "\t", " \n\t "]
    )
    func throwsOnBlankVariableName(variableName: String) {
        #expect(
            throws: ClaudeCredentialProviderError.emptyEnvironmentVariableName
        ) {
            _ = try ClaudeEnvironmentCredentialProvider(
                variableName: variableName,
                environment: [:]
            )
        }
    }

    @Test("Excludes the API key from descriptions and reflection")
    func redactsKey() throws {
        // Given
        let sut = try ClaudeEnvironmentCredentialProvider(
            variableName: "CUSTOM_KEY",
            environment: ["CUSTOM_KEY": "sk-test-key"]
        )
        var dumped = ""

        // When
        dump(sut, to: &dumped)

        // Then
        #expect(!String(describing: sut).contains("sk-test-key"))
        #expect(!String(reflecting: sut).contains("sk-test-key"))
        #expect(!dumped.contains("sk-test-key"))
    }
}
