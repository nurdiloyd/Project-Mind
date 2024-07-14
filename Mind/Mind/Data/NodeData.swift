import SwiftData
import Foundation
import PhotosUI

@Model
final class NodeData {
    @Attribute(.unique) var id: UUID
    var title: String = ""
    var localPositionX: Double = 0
    var localPositionY: Double = 0
    var lastPositionX: Double = 0
    var lastPositionY: Double = 0
    var imageName: String? = nil
    var order: Int = 0
    @Relationship var parent: NodeData? = nil
    @Relationship(inverse: \NodeData.parent) var children: [NodeData] = []
    var height: Double = NodeView.minHeight
    var contentHeight: Double = 0
    var isExpanded: Bool = false
    
    @Transient var globalPositionX: Double { localPositionX + (parent?.globalPositionX ?? 0) }
    @Transient var globalPositionY: Double { localPositionY + (parent?.globalPositionY ?? 0) }
    @Transient var globalHeight: Double { isExpandable
                                            ? isExpanded
                                                ? max(height, contentHeight)
                                                : height
                                            : height }
    @Transient var isExpandable: Bool {children.count > 0}
    @Transient() var image: NSImage? = nil
    @Attribute(.ephemeral) var newlyCreated: Bool = false
    
    init(title: String, positionX: Double = 0, positionY: Double = 0, parent: NodeData? = nil) {
        self.id = UUID()
        self.title = "\(title)"
        self.localPositionX = positionX
        self.localPositionY = positionY
        self.lastPositionX = positionX
        self.lastPositionY = positionY
        self.parent = parent
        self.newlyCreated = true
        
        if let prnt = parent
        {
            prnt.addChild(node: self)
        }
    }

    private func addChild(node: NodeData) {
        isExpanded = true
        node.order = (children.max(by: { $0.order < $1.order })?.order ?? 0) + 1
        children.append(node)
    }
}
