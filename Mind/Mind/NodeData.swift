import SwiftData
import Foundation

@Model
final class NodeData {
    @Attribute(.unique) var id: UUID
    var title: String
    var positionX: Double
    var positionY: Double
    var lastPositionX: Double
    var lastPositionY: Double
    var imageName: String?
    @Relationship var parent: NodeData?
    @Relationship(inverse: \NodeData.parent) var children: [NodeData] = []
    
    init(id: UUID = UUID(), title: String, positionX: Double, positionY: Double, imageName: String? = nil, parent: NodeData? = nil) {
        self.id = id
        self.title = title
        self.positionX = positionX
        self.positionY = positionY
        self.lastPositionX = positionX
        self.lastPositionY = positionY
        self.imageName = imageName
        self.parent = parent
    }
    
    public func addChild(node: NodeData)
    {
        children.append(node)
    }
}
