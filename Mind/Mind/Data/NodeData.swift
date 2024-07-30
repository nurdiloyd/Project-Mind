import SwiftData
import Foundation
import PhotosUI
import SwiftUI

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
    @Transient var isExpandable: Bool {children.count > 0}
    @Transient var hasParent: Bool { return parent != nil }
    @Transient var globalHeight: Double { isExpandable
                                            ? isExpanded
                                                ? max(height, contentHeight)
                                                : height
                                            : height }
    @Transient var shouldShowSelf: Bool { !hasParent || (parent?.shouldShowChildren ?? false) }
    @Transient var canShowChildren: Bool { children.count > 0 && shouldShowSelf }
    @Transient var shouldShowChildren: Bool { isExpanded && canShowChildren }
    
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
            setLocalPosition(positionX: globalPositionX, positionY: globalPositionY)
            setLastLocalPosition(positionX: snapX(lastGlobalPositionX), positionY: snapY(lastGlobalPositionY))
            
            prnt.removeChild(self)
        }
    }
    
    public func snapToGrid() {
        let positionX = snapX(localPositionX)
        let positionY = snapY(localPositionY)
        
        setLocalPosition(positionX: positionX, positionY: positionY)
        resetLastLocalPosition()
    }
    
    public func snapX(_ positionX: Double) -> Double
    {
        return (positionX / NodeView.snapX).rounded() * NodeView.snapX
    }
    
    public func snapY(_ positionY: Double) -> Double
    {
        return (positionY / NodeView.snapY).rounded() * NodeView.snapY
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
        setLastLocalPosition(positionX: localPositionX, positionY: localPositionY)
    }
    
    public func setTitle(title: String) {
        let trimmedTitle = title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTitle.isEmptyOrWithWhiteSpace {
            self.title = trimmedTitle
        }
    }
    
    public func rearrangeChildrenPositionY() {
        let sortedChildren = children.sorted(by: { $0.order > $1.order })
        
        var totalHeight = -NodeView.vStackSpace
        for child in sortedChildren {
            totalHeight += child.globalHeight + NodeView.vStackSpace
        }
        
        contentHeight = totalHeight
        
        var currentY = totalHeight / 2
        for child in sortedChildren {
            let positionX = NodeView.snapX
            let positionY = currentY - child.globalHeight / 2
            child.setLocalPosition(positionX: positionX, positionY: positionY)
            child.resetLastLocalPosition()
            currentY -= (child.globalHeight + NodeView.vStackSpace)
        }
    }
    
    public func rearrangeSiblingsPositionY()
    {
        if let prnt = parent {
            prnt.rearrangeChildrenPositionY()
            prnt.rearrangeSiblingsPositionY()
        }
    }
}
