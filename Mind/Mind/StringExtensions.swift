//
//  StringExtensions.swift
//  Mind
//
//  Created by Nurdogan Karaman on 4.07.2024.
//

import Foundation

extension String {
    var isEmptyOrWithWhiteSpace: Bool {
        self.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
