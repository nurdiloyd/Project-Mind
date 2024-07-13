import SwiftData
import Foundation

@Model
final class NodeData {
    @Attribute(.unique) var id: UUID
    var title: String = ""
    var globalPositionX: Double { localPositionX + (parent?.globalPositionX ?? 0) }
    var globalPositionY: Double { localPositionY + (parent?.globalPositionY ?? 0) }
    var localPositionX: Double = 0
    var localPositionY: Double = 0
    var lastPositionX: Double = 0
    var lastPositionY: Double = 0
    var imageName: String? = nil
    var order: Int = 0
    @Relationship var parent: NodeData? = nil
    @Relationship(inverse: \NodeData.parent) var children: [NodeData] = []
    var containerHeight: Double = NodeView.minHeight
    var isSelected: Bool = false
    
    init(title: String, positionX: Double = 0, positionY: Double = 0, parent: NodeData? = nil) {
        self.id = UUID()
        self.title = "\(title)"
        self.localPositionX = positionX
        self.localPositionY = positionY
        self.lastPositionX = positionX
        self.lastPositionY = positionY
        self.parent = parent
        
        parent?.addChild(node: self)
    }

    private func addChild(node: NodeData) {
        node.order = (children.max(by: { $0.order < $1.order })?.order ?? 0) + 1
        children.append(node)
    }
}
