import SwiftUI
import PhotosUI

struct NodeTreeView: View {
    let node: NodeData
    public var createNode: (String, CGFloat, CGFloat, NodeData) -> Void
    public var deleteNode: (NodeData) -> Void
    public var saveContext: () -> Void

    var body: some View {
        if node.children.count > 0 {
            VStack {
                ForEach(node.children, id: \.id) { child in
                    NodeContainerView(node: child,
                                      createNode: createNode,
                                      deleteNode: deleteNode,
                                      saveContext: saveContext)
                }
            }
            .background(.gray)
            .cornerRadius(10)
            .position(x:node.positionX + 150 + 30, y: node.positionY)
            
            ForEach(node.children, id: \.id) { child in
                NodeTreeView(node: child,
                             createNode: createNode,
                             deleteNode: deleteNode,
                             saveContext: saveContext)
            }
        }
    }
}
