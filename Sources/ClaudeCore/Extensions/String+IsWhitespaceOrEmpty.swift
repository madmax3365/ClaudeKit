//
//  String+IsWhitespaceOrEmpty.swift
//  ClaudeCore
//
//  Created by Gagik Muradyan on 22.10.26.
//

import Foundation

extension String {
    var isWhitespaceOrEmpty: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
