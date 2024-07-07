import SwiftData
import Foundation

@Model
final class NodeData {
    @Attribute(.unique) var id: UUID
    var title: String
    var globalPositionX: Double { localPositionX + (parent?.globalPositionX ?? 0)}
    var globalPositionY: Double { localPositionY + (parent?.globalPositionY ?? 0)}
    var localPositionX: Double = 0
    var localPositionY: Double = 0
    var lastPositionX: Double
    var lastPositionY: Double
    var imageName: String?
    @Relationship var parent: NodeData?
    @Relationship(inverse: \NodeData.parent) var children: [NodeData] = []
    var containerHeight: Double = 106
    
    init(id: UUID = UUID(), title: String, positionX: Double, positionY: Double, imageName: String? = nil, parent: NodeData? = nil) {
        self.id = id
        self.localPositionX = positionX
        self.localPositionY = positionY
        self.lastPositionX = positionX
        self.lastPositionY = positionY
        self.imageName = imageName
        self.parent = parent
        self.containerHeight = 106
        self.title = "\(title)"
        
        parent?.addChild(node: self)
    }
    
    public func addChild(node: NodeData)
    {
        children.append(node)
    }
}
