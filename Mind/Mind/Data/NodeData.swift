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
    var imageName: String = ""
    var order: Int = 0
    @Relationship var parent: NodeData? = nil
    @Relationship(inverse: \NodeData.parent) var children: [NodeData] = []
    var height: Double = NodeView.minHeight
    var contentHeight: Double = 0
    var expandedContentHeight: Double = 0
    var isExpanded: Bool = false
    var isInit: Bool = false
    var contentInfo: String = ""
    
    @Transient var globalPositionX: Double { localPositionX + (parent?.globalPositionX ?? 0) }
    @Transient var globalPositionY: Double { localPositionY + (parent?.globalPositionY ?? 0) }
    @Transient var lastGlobalPositionX: Double { lastLocalPositionX + (parent?.globalPositionX ?? 0) }
    @Transient var lastGlobalPositionY: Double { lastLocalPositionY + (parent?.globalPositionY ?? 0) }
    @Transient var isExpandable: Bool {children.count > 0}
    @Transient var hasParent: Bool { parent != nil }
    @Transient var globalHeight: Double { max(height, isExpanded ? expandedContentHeight : contentHeight) }
    @Transient var shouldShowSelf: Bool { !hasParent || (parent?.shouldShowChildren ?? false) }
    @Transient var canShowChildren: Bool { children.count > 0 && shouldShowSelf }
    @Transient var shouldShowChildren: Bool { isExpanded && canShowChildren }
    @Transient var contentGlobalPositionX: Double { contentLocalPositionX + globalPositionX }
    @Transient var contentGlobalPositionY: Double { contentLocalPositionY + globalPositionY }
    @Transient var isLastChild: Bool {
        if let prnt = parent {
            return prnt.children.min(by: { $0.order > $1.order })?.id == self.id
        }
        else {
            return false
        }
    }

    init(title: String, positionX: Double = 0, positionY: Double = 0) {
        self.id = UUID()
        self.title = "\(title)"
        self.localPositionX = positionX
        self.localPositionY = positionY
        self.lastLocalPositionX = positionX
        self.lastLocalPositionY = positionY
    }
    
    public func addChild(_ child: NodeData) {
        child.parent = self
        child.order = (children.max(by: { $0.order < $1.order })?.order ?? 0) + 1
        children.append(child)
        
        isExpanded = true
        rearrangeSelfAndParent()
    }
    
    private func removeChild(_ child: NodeData) {
        child.place(positionX: child.globalPositionX, positionY: child.globalPositionY)
        child.parent = nil
        
        if let index = children.firstIndex(of: child)
        {
            children.remove(at: index)
        }
        
        rearrangeSelfAndParent()
    }
    
    public func removeAllChildren()
    {
        for child in children {
            child.place(positionX: child.globalPositionX, positionY: child.globalPositionY)
            child.parent = nil
            
            if let index = children.firstIndex(of: child)
            {
                children.remove(at: index)
            }
        }
        
        rearrangeSelfAndParent()
    }
    
    public func removeParent()
    {
        if let prnt = parent {
            prnt.removeChild(self)
        }
    }
    
    public func place(positionX: Double, positionY: Double, snap: Bool = true) {
        let posX = snap ? snapX(positionX) : positionX
        let posY = snap ? snapY(positionY) : positionY
        
        setLocalPosition(positionX: posX, positionY: posY)
        setLastLocalPosition(positionX: posX, positionY: posY)
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
    
    
    public func setTitle(title: String) {
        let trimmedTitle = title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTitle.isEmptyOrWithWhiteSpace {
            self.title = trimmedTitle
        }
        
        if let prnt = parent {
            prnt.resetContentInfoText()
        }
    }
    
    public func setHeight(height: Double)
    {
        if self.height != height
        {
            self.height = height
            rearrangeParent()
        }
    }
    
    public func toggleExpand()
    {
        isExpanded.toggle()
        
        rearrangeContent()
        rearrangeParent()
    }
    
    public func rearrangeSelfAndParent()
    {
        rearrangeChildrenPositionY()
        rearrangeParent()
    }
    
    private func rearrangeParent()
    {
        if let prnt = parent {
            prnt.rearrangeSelfAndParent()
        }
    }
    
    private func rearrangeChildrenPositionY() {
        let sortedChildren = children.sorted(by: { $0.order > $1.order })
        
        var totalHeight = -NodeView.vStackSpace
        for child in sortedChildren {
            totalHeight += child.globalHeight + NodeView.vStackSpace
        }
        
        var currentY = totalHeight / 2
        for child in sortedChildren {
            let posX = NodeView.snapX
            let posY = currentY - child.globalHeight / 2
            
            child.place(positionX: posX, positionY: posY, snap: false)
            
            currentY -= (child.globalHeight + NodeView.vStackSpace)
        }
        
        expandedContentHeight = totalHeight
        
        rearrangeContent()
    }
    
    private func rearrangeContent() {
        if let fNode = children.max(by: { $0.order < $1.order }) {
            if let lNode = children.min(by: { $0.order < $1.order }) {
                let fPosX = fNode.lastLocalPositionX
                let lPosX = lNode.lastLocalPositionX
                
                if isExpanded {
                    let fPosY = fNode.lastLocalPositionY
                    let lPosY = lNode.lastLocalPositionY
                    
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
    
    private func resetContentInfoText()
    {
        contentInfo = children.filter({ NodeData in
            !NodeData.title.isEmptyOrWithWhiteSpace
        }).sorted(by: { $0.order < $1.order })
                .map { "\($0.title)" }
                .joined(separator: " ")
    }
}
