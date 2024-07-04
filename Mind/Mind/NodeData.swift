import SwiftData
import Foundation

@Model
final class NodeData {
    @Attribute(.unique) var id: UUID
    var title: String
    var position: CGSize
    var lastPosition: CGSize
    var imageName: String?
    var parent: NodeData?
    var children: [NodeData] = []

    init(id: UUID = UUID(), title: String, position: CGSize, imageName: String? = nil, parent: NodeData? = nil) {
        self.id = id
        self.title = title
        self.position = position
        self.lastPosition = position
        self.imageName = imageName
        self.parent = parent
    }
}
