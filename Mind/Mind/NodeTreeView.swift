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
                if let fNode = children.first
                {
                    if let lNode = children.last
                    {
                        let posX = (fNode.globalPositionX + lNode.globalPositionX) / 2
                        let posY = (fNode.globalPositionY + lNode.globalPositionY) / 2
                        let padding = 3.0
                        let cornerRadius = NodeView.cornerRadius + padding / 2
                        let width = NodeView.width + padding * 2
                        let height = abs(fNode.globalPositionY - lNode.globalPositionY)
                            + fNode.height / 2
                            + lNode.height / 2
                            + padding * 2
                        RoundedRectangle(cornerRadius: cornerRadius)
                            
                            .frame(width: width, height: height)
                            
                            .shadow(radius: NodeView.shadow * 2)
                            
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
