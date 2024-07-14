import SwiftData
import Foundation

@Model
class BoardData {
    @Attribute(.unique) var id: UUID
    var title: String
    @Relationship var nodes: [NodeData] = []
    var isInit: Bool = false
    
    init(title: String) {
        self.id = UUID()
        self.title = title
    }
}