//
//  ToDo.swift
//  Project-Mind
//
//  Created by Nurdogan Karaman on 3.07.2024.
//

import Foundation
import SwiftData

@Model
final class ToDo: Identifiable {

    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var note: String

    init(id: UUID = UUID(), name: String, note: String) {
        self.id = id
        self.name = name
        self.note = note
    }
}
