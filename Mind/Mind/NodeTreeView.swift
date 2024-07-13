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
            ForEach(node.children.sorted(by: { $0.order > $1.order })) { child in
                NodeTreeView(node: child,
                             createNode: createNode,
                             deleteNode: deleteNode,
                             saveContext: saveContext)
            }
        }
    }
}
