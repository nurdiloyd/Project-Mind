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
    var contentLocalPositionX: Double = 0
    var contentLocalPositionY: Double = 0
    var imageName: String? = nil
    var order: Int = 0
    @Relationship var parent: NodeData? = nil
    @Relationship(inverse: \NodeData.parent) var children: [NodeData] = []
    var height: Double = NodeView.minHeight
    var contentHeight: Double = 0
    var isExpanded: Bool = false
    var isInit: Bool = false
    var contentInfo: String = ""
    
    @Transient var globalPositionX: Double { localPositionX + (parent?.globalPositionX ?? 0) }
    @Transient var globalPositionY: Double { localPositionY + (parent?.globalPositionY ?? 0) }
    @Transient var lastGlobalPositionX: Double { lastLocalPositionX + (parent?.globalPositionX ?? 0) }
    @Transient var lastGlobalPositionY: Double { lastLocalPositionY + (parent?.globalPositionY ?? 0) }
    @Transient var isExpandable: Bool {children.count > 0}
    @Transient var hasParent: Bool { parent != nil }
    @Transient var globalHeight: Double { max(height, contentHeight) }
    @Transient var shouldShowSelf: Bool { !hasParent || (parent?.shouldShowChildren ?? false) }
    @Transient var canShowChildren: Bool { children.count > 0 && shouldShowSelf }
    @Transient var shouldShowChildren: Bool { isExpanded && canShowChildren }
    @Transient var contentGlobalPositionX: Double { contentLocalPositionX + globalPositionX }
    @Transient var contentGlobalPositionY: Double { contentLocalPositionY + globalPositionY }
    @Transient var isLastChild: Bool {
        if let prnt = parent {
            return prnt.children.min(by: { $0.order > $1.order })?.id == self.id
        }
        
        return true
    }

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
        
        resetContentInfoText()
    }
    
    public func removeChild(_ nodeData: NodeData) {
        nodeData.parent = nil
        if let parentIndex = children.firstIndex(of: nodeData)
        {
            children.remove(at: parentIndex)
        }
        
        resetContentInfoText()
    }
    
    public func resetContentInfoText()
    {
        contentInfo = children.filter({ NodeData in
            !NodeData.title.isEmptyOrWithWhiteSpace
        }).sorted(by: { $0.order < $1.order })
                .map { "\($0.title)" }
                .joined(separator: " ")
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
        
        if let prnt = parent {
            prnt.resetContentInfoText()
        }
    }
    
    public func rearrangeChildrenPositionY() {
        let sortedChildren = children.sorted(by: { $0.order > $1.order })
        
        var totalHeight = -NodeView.vStackSpace
        for child in sortedChildren {
            totalHeight += child.globalHeight + NodeView.vStackSpace
        }
        
        var currentY = totalHeight / 2
        for child in sortedChildren {
            let positionX = NodeView.snapX
            let positionY = currentY - child.globalHeight / 2
            child.setLocalPosition(positionX: positionX, positionY: positionY)
            child.resetLastLocalPosition()
            currentY -= (child.globalHeight + NodeView.vStackSpace)
        }
        
        rearrangeContent()
    }
    
    public func rearrangeSiblingsPositionY()
    {
        if let prnt = parent {
            prnt.rearrangeChildrenPositionY()
            prnt.rearrangeSiblingsPositionY()
        }
    }
    
    public func toggleExpand()
    {
        isExpanded.toggle()
        
        rearrangeContent()
        rearrangeSiblingsPositionY()
    }
    
    private func rearrangeContent()
    {
        if let fNode = children.max(by: { $0.globalPositionY < $1.globalPositionY }) {
            if let lNode = children.min(by: { $0.globalPositionY < $1.globalPositionY }) {
                let fPosX = fNode.lastLocalPositionX
                let lPosX = lNode.lastLocalPositionX
                
                if isExpanded {
                    let fPosY = fNode.localPositionY
                    let lPosY = lNode.localPositionY
                    
                    contentLocalPositionX = (fPosX + lPosX) / 2
                    contentLocalPositionY = (fPosY + fNode.height / 2 + lPosY - lNode.height / 2) / 2
                    contentHeight = abs(fPosY - lPosY) + fNode.height / 2 + lNode.height / 2
                }
                else {
                    let lineCount = (CGFloat(contentInfo.count) / 24.3).rounded()
                    let lineHeight = 7.4
                    let lineSpace = 5.8
                    let totalLineHeight = (lineHeight * lineCount + lineSpace * (lineCount - 1)).clamped(to: NodeView.minHeight...NodeView.maxHeight)
                    let rowHeight = NodeView.minHeight + NodeView.vStackSpace
                    let nodeCount = ((totalLineHeight + NodeView.vStackSpace) / rowHeight).rounded(.up)
                    
                    contentLocalPositionX = (fPosX + lPosX) / 2
                    contentLocalPositionY = 0
                    contentHeight = rowHeight * nodeCount - NodeView.vStackSpace
                }
            }
        }
        
        resetContentInfoText()
    }
}
