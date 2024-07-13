import SwiftData
import Foundation

@Model
final class BoardData {
    @Attribute(.unique) var id: UUID
    var title: String
    @Relationship var nodes: [NodeData] = []

    init(title: String) {
        self.id = UUID()
        self.title = title
    }
}
