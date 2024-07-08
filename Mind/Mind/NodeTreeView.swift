
import SwiftUI
import SwiftData

struct NodeTreeView: View {
    let node: NodeData
    public var createNode: (String, CGFloat, CGFloat, NodeData) -> Void
    public var deleteNode: (NodeData) -> Void
    public var saveContext: () -> Void
    
    var body: some View {
        NodeContainerView(node: node,
                      createNode: createNode,
                      deleteNode: deleteNode,
                      saveContext: saveContext)
        
        ForEach(node.children) { child in
            NodeTreeView(node: child,
                         createNode: createNode,
                         deleteNode: deleteNode,
                         saveContext: saveContext)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [NodeData.self])
}
