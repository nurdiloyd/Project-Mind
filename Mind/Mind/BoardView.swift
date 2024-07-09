import SwiftUI
import SwiftData

struct BoardView: View {
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<NodeData> { nodeData in
        nodeData.parent == nil
    }) private var nodes: [NodeData]
    
    @State private var showBoardPage: Bool = false
    @State private var lastScaleValue: CGFloat = 1.0
    @State private var scale: CGFloat = 1.0
    @State private var boxSize: CGFloat = 300
    @State private var currentSize: CGSize = .zero
    static let boardSize: CGFloat = 10000

    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: true) {
            ZStack {
                ZStack {
                    ForEach(nodes, id: \.id) { node in
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
            ToolbarItem {
                Button {
                    let positionX = BoardView.boardSize / 2
                    let positionY = BoardView.boardSize / 2
                    createNode(title: "Title", positionX: positionX, positionY: positionY)
                } label: {
                    Image(systemName: "plus.circle")
                }
            }

            ToolbarItem {
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
        withAnimation {
            let newNode = NodeData(title: title,
                                   positionX: Double(positionX),
                                   positionY: Double(positionY),
                                   imageName: "",
                                   parent: parent)
            
            insertNode(newNode)
            saveContext()
        }
    }

    private func clearBoard() {
        for node in nodes {
            deleteNode(node)
        }
        
        saveContext()
    }
    
    public func insertNode(_ node: NodeData) {
        context.insert(node)
    }

    public func deleteNode(_ node: NodeData) {
        context.delete(node)
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

#Preview {
    ContentView()
        .modelContainer(for: [NodeData.self])
}