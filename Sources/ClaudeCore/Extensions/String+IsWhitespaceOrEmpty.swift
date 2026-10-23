//
//  String+IsWhitespaceOrEmpty.swift
//  ClaudeCore
//
//  Created by Gagik Muradyan on 22.10.26.
//  Copyright © 2026 Gagik Muradyan. All rights reserved.
//

import Foundation

extension String {
    var isWhitespaceOrEmpty: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
