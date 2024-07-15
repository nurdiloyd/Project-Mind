import SwiftUI
import SwiftData
import Cocoa

struct BoardView: View {
    @Environment(\.modelContext) private var context
    let board: BoardData
    let onBack: () -> Void
    
    @State private var lastScaleValue: CGFloat = 1.0
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
                            .frame(width: 50, height: 50)
                            .foregroundStyle(Color(NSColor.windowFrameTextColor))

                        ForEach(board.nodes.filter({ node in
                            node.parent == nil
                        }), id: \.id) { node in
                            NodeTreeView(node: node,
                                         createNode: {title, parent in
                                createNode(title: title, parent: parent)
                            },
                                         deleteNode: deleteNode,
                                         saveContext: saveContext)
                        }
                    }
                    .frame(width: BoardView.boardWidth, height: BoardView.boardHeight)
                    .scaleEffect(scale)
                }
                .frame(width: BoardView.boardWidth * scale, height: BoardView.boardHeight * scale)
                .background(Color(NSColor.windowBackgroundColor))
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
        var boardAspectRatio = BoardView.boardWidth / BoardView.boardHeight
        var windowAspectRatio = geometrySize.width / geometrySize.height
        let minEdgeLength = min(geometrySize.width, geometrySize.height)
        let maxScale = minEdgeLength / BoardView.boxSize

        if boardAspectRatio > windowAspectRatio {
            let minScale = geometrySize.width / (BoardView.boardWidth*1)
            let newScale = value.clamped(to: minScale...maxScale)
            return newScale
        }
        else {
            let minScale = geometrySize.height / (BoardView.boardHeight*1)
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
