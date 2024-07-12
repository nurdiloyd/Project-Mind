import SwiftUI
import SwiftData
import Cocoa

struct BoardView: View {
    @Environment(\.modelContext) private var context
    let board: BoardData
    let onBack: () -> Void
    
    @State private var lastScaleValue: CGFloat = 1.0
    @State private var scale: CGFloat = 1.0
    @State private var boxSize: CGFloat = 300
    @State private var currentSize: CGSize = .zero
    static let boardSize: CGFloat = 10000

    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: true) {
            ZStack {
                ZStack {
                    ForEach(board.nodes.filter({ node in
                        node.parent == nil
                    }), id: \.id) { node in
                        NodeTreeView(node: node,
                                     createNode: createNode,
                                     deleteNode: deleteNode,
                                     saveContext: saveContext)
                    }
                }
                .frame(width: BoardView.boardSize, height: BoardView.boardSize)
                .scaleEffect(self.scale)
            }
            .frame(width: BoardView.boardSize * self.scale, height: BoardView.boardSize * self.scale)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .defaultScrollAnchor(.center)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                Button(action: {
                    onBack()
                }) {
                    Image(systemName: "house")
                }
                
                Text(board.title)
                    .font(.headline)
            }
            
            ToolbarItemGroup(placement: .primaryAction) {
                Spacer()
                Button {
                    let positionX = BoardView.boardSize / 2
                    let positionY = BoardView.boardSize / 2
                    createNode(title: "Title", positionX: positionX, positionY: positionY)
                } label: {
                    Image(systemName: "plus.circle")
                }
                
                Button {
                    clearBoard()
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(Color(NSColor.systemRed))
                }
            }
        }
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    self.scale = self.getScale(for: currentSize, value: self.lastScaleValue * value)
                }
                .onEnded { value in
                    self.lastScaleValue = self.scale
                }
        )
        .readSize { size in
            currentSize = size
            self.scale = self.getScale(for: currentSize, value: self.scale)
            self.lastScaleValue = self.scale
        }
    }

    private func getScale(for geometrySize: CGSize, value: CGFloat) -> CGFloat {
        let minEdgeLength = min(geometrySize.width, geometrySize.height)
        let minScale: CGFloat = minEdgeLength / BoardView.boardSize
        let maxScale: CGFloat = minEdgeLength / self.boxSize
        let newScale = value.clamped(to: minScale...maxScale)
        return newScale
    }

    private func createNode(title: String, positionX: CGFloat, positionY: CGFloat, parent: NodeData? = nil) {
        let newNode = NodeData(title: title,
                               positionX: Double(positionX),
                               positionY: Double(positionY),
                               imageName: "",
                               parent: parent)

        board.nodes.append(newNode)
        insertNodeData(newNode)
        saveContext()
    }

    private func deleteNode(_ nodeData: NodeData) -> Bool
    {
        if let index = board.nodes.firstIndex(of: nodeData)
        {
            if let parent = nodeData.parent {
                if let parentIndex = parent.children.firstIndex(of: nodeData)
                {
                    parent.children.remove(at: parentIndex)
                }
            }
            
            deleteNodeData(nodeData)
            board.nodes.remove(at: index)
            saveContext()
            
            return true
        }
        
        return false
    }
    
    private func clearBoard() {
        for node in board.nodes {
            deleteNodeData(node)
        }
        
        board.nodes.removeAll()
        saveContext()
    }
    
    public func insertNodeData(_ nodeData: NodeData) {
        context.insert(nodeData)
    }

    public func deleteNodeData(_ nodeData: NodeData) {
        context.delete(nodeData)
    }
    
    public func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
