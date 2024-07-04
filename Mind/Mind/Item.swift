//
//  Item.swift
//  Mind
//
//  Created by Nurdogan Karaman on 3.07.2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
