import SwiftUI
import SwiftData

struct NodeTreeView: View {
    let node: NodeData
    public var createNode: (String, NodeData) -> Void
    public var deleteNode: (NodeData) -> Bool
    public var saveContext: () -> Void
    
    var body: some View {
        NodeView(node: node,
                 createNode: createNode,
                 deleteNode: deleteNode,
                 saveContext: saveContext)
        
        if node.isExpanded {
            if node.children.count > 0
            {
                let children = node.children.sorted(by: { $0.order > $1.order })
                
                if let fNode = node.children.max(by: { $0.globalPositionY < $1.globalPositionY })
                {
                    if let lNode = node.children.min(by: { $0.globalPositionY < $1.globalPositionY }) {
                        let fPosX = fNode.lastGlobalPositionX
                        let fPosY = fNode.globalPositionY
                        let lPosX = lNode.lastGlobalPositionX
                        let lPosY = lNode.globalPositionY
                        
                        let posX = (fPosX + lPosX) / 2
                        let posY = (fPosY + fNode.height / 2 + lPosY - lNode.height / 2) / 2
                        let padding = 3.0
                        let cornerRadius = LCConstants.cornerRadius + padding / 2
                        let width = NodeView.width + padding * 2
                        let height = abs(fPosY - lPosY) + fNode.height / 2 + lNode.height / 2 + padding * 2
                        
                        Rectangle()
                            .fill(LCConstants.getColor(1))
                            .frame(width: width, height: height)
                            .LCContainer(radius: cornerRadius)
                            .position(CGPoint(x: CGFloat(posX), y: CGFloat(posY)))
                    }
                }
                
                ForEach(children) { child in
                    NodeTreeView(node: child,
                                 createNode: createNode,
                                 deleteNode: deleteNode,
                                 saveContext: saveContext)
                }
            }
        }
    }
}
