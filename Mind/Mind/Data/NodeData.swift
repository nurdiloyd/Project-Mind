import SwiftData
import Foundation
import PhotosUI

@Model
final class NodeData {
    @Attribute(.unique) var id: UUID
    var title: String = ""
    var localPositionX: Double = 0
    var localPositionY: Double = 0
    var lastLocalPositionX: Double = 0
    var lastLocalPositionY: Double = 0
    var imageName: String? = nil
    var order: Int = 0
    @Relationship var parent: NodeData? = nil
    @Relationship(inverse: \NodeData.parent) var children: [NodeData] = []
    var height: Double = NodeView.minHeight
    var contentHeight: Double = 0
    var isExpanded: Bool = false
    var isInit: Bool = false
    
    @Transient var globalPositionX: Double { localPositionX + (parent?.globalPositionX ?? 0) }
    @Transient var globalPositionY: Double { localPositionY + (parent?.globalPositionY ?? 0) }
    @Transient var lastGlobalPositionX: Double { lastLocalPositionX + (parent?.globalPositionX ?? 0) }
    @Transient var lastGlobalPositionY: Double { lastLocalPositionY + (parent?.globalPositionY ?? 0) }
    @Transient var globalHeight: Double { isExpandable
                                            ? isExpanded
                                                ? max(height, contentHeight)
                                                : height
                                            : height }
    @Transient var isExpandable: Bool {children.count > 0}
    @Transient var hasParent: Bool { return parent != nil }
    
    init(title: String, positionX: Double = 0, positionY: Double = 0, parent: NodeData? = nil) {
        self.id = UUID()
        self.title = "\(title)"
        self.localPositionX = positionX
        self.localPositionY = positionY
        self.lastLocalPositionX = positionX
        self.lastLocalPositionY = positionY
        self.parent = parent
        
        if let prnt = parent
        {
            prnt.addChild(self)
        }
    }

    private func addChild(_ nodeData: NodeData) {
        isExpanded = true
        nodeData.order = (children.max(by: { $0.order < $1.order })?.order ?? 0) + 1
        children.append(nodeData)
    }
    
    public func removeChild(_ nodeData: NodeData) {
        nodeData.parent = nil
        if let parentIndex = children.firstIndex(of: nodeData)
        {
            children.remove(at: parentIndex)
        }
    }
    
    public func removeParent()
    {
        if let prnt = parent {
            prnt.removeChild(self)
        }
    }
    
    public func setLocalPosition(positionX: Double, positionY: Double) {
        localPositionX = positionX
        localPositionY = positionY
    }
    
    public func setLastLocalPosition(positionX: Double, positionY: Double) {
        lastLocalPositionX = positionX
        lastLocalPositionY = positionY
    }
    
    public func resetLastLocalPosition() {
        lastLocalPositionX = localPositionX
        lastLocalPositionY = localPositionY
    }
    
    public func setTitle(title: String) {
        let trimmedTitle = title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTitle.isEmptyOrWithWhiteSpace {
            self.title = trimmedTitle
        }
    }
}
