import SwiftUI
import SwiftData
import Cocoa

struct BoardView: View {
    @Environment(\.modelContext) private var context
    let board: BoardData
    let onBack: () -> Void
    
    @State private var lastScale: CGFloat = 1.0
    @State private var scale: CGFloat = 1.0
    @State private var currentSize: CGSize = .zero
    private static var boxSize: CGFloat = NodeView.maxHeight
    public static let boardWidth: CGFloat = 100 * NodeView.snapX
    public static let boardHeight: CGFloat = 400 * NodeView.snapY
    
    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: true) {
            ZStack{
                ZStack {
                    ZStack {
                        Circle()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color(NSColor.windowFrameTextColor))

                        ForEach(board.nodes.filter({ node in
                            node.parent == nil
                        }), id: \.id) { node in
                            NodeTreeView(node: node,
                                         createNode: {title, parent in
                                                createNode(title: title, parent: parent)
                                         },
                                         deleteNode: deleteNode)
                        }
                    }
                    .frame(width: BoardView.boardWidth, height: BoardView.boardHeight)
                    .scaleEffect(scale)
                }
                .frame(width: BoardView.boardWidth * scale, height: BoardView.boardHeight * scale)
            }
            .background(LCConstants.groundColor)
            .onTapGesture(count: 2) {
                withAnimation {
                    scale = getNormalScale(for: currentSize)
                    lastScale = scale
                }
            }
        }
        .defaultScrollAnchor(.center)
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
                    let positionX = BoardView.boardWidth / 2
                    let positionY = BoardView.boardHeight / 2
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
                    scale = getScale(for: currentSize, value: lastScale * value)
                }
                .onEnded { value in
                    lastScale = scale
                }
        )
        .readSize { size in
            currentSize = size
            scale = getScale(for: currentSize, value: lastScale)
            lastScale = scale
        }
    }

    private func getNormalScale(for size: CGSize) -> CGFloat
    {
        let minEdgeLength = min(size.width, size.height)
        let normalScale = minEdgeLength / (BoardView.boxSize * 5)
        return getScale(for: size, value: normalScale)
    }
    
    private func getScale(for size: CGSize, value: CGFloat) -> CGFloat {
        let boardAspectRatio = BoardView.boardWidth / BoardView.boardHeight
        let windowAspectRatio = size.width / size.height
        let minEdgeLength = min(size.width, size.height)
        let maxScale = minEdgeLength / BoardView.boxSize

        if boardAspectRatio > windowAspectRatio {
            let minScale = size.width / (BoardView.boardWidth * 1.0)
            let newScale = value.clamped(to: minScale...maxScale)
            return newScale
        }
        else {
            let minScale = size.height / (BoardView.boardHeight * 1.0)
            let newScale = value.clamped(to: minScale...maxScale)
            return newScale
        }
    }

    private func createNode(title: String, parent: NodeData? = nil, positionX: CGFloat = 0, positionY: CGFloat = 0) {
        let newNode = NodeData(title: title,
                               positionX: Double(positionX),
                               positionY: Double(positionY),
                               parent: parent)

        board.nodes.append(newNode)
        insertNodeData(newNode)
    }

    private func deleteNode(_ nodeData: NodeData) -> Bool
    {
        if let index = board.nodes.firstIndex(of: nodeData)
        {
            nodeData.removeParent()
            deleteNodeData(nodeData)
            board.nodes.remove(at: index)
            
            return true
        }
        
        return false
    }
    
    private func clearBoard() {
        for node in board.nodes {
            deleteNodeData(node)
        }
        
        board.nodes.removeAll()
    }
    
    public func insertNodeData(_ nodeData: NodeData) {
        context.insert(nodeData)
    }

    public func deleteNodeData(_ nodeData: NodeData) {
        FileHelper.deleteImage(filename: nodeData.imageName)
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
