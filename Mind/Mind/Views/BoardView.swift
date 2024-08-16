import SwiftUI
import SwiftData
import Cocoa

struct BoardView: View {
    @Environment(\.modelContext) private var context
    let board: BoardData
    let onBack: () -> Void
    
    @State private var sortedNodes: [NodeData] = [NodeData]()
    @State private var lastScale: CGFloat = 1.0
    @State private var scale: CGFloat = 1.0
    @State private var currentSize: CGSize = .zero
    private static var boxSize: CGFloat = NodeView.maxHeight
    public static let boardWidth: CGFloat = 100 * NodeView.snapX
    public static let boardHeight: CGFloat = 400 * NodeView.snapY
    
    var body: some View {
        Group {
            if (!board.isFlashCardView)
            {
                ScrollView([.horizontal, .vertical], showsIndicators: true) {
                    ZStack{
                        ZStack {
                            ZStack {
                                ZStack{
                                    Circle()
                                        .foregroundStyle(Color(NSColor.windowFrameTextColor))
                                        .frame(width: 40, height: 40)
                                    Text("\(board.nodes.count)")
                                        .foregroundStyle(Color(NSColor.windowBackgroundColor))
                                        .font(.headline)
                                }
                                
                                ForEach(sortedNodes, id: \.id) { node in
                                    if node.shouldShowSelf {
                                        NodeView(node: node,
                                                 createNode: { parent in createNode(parent: parent) },
                                                 deleteNode: deleteNode,
                                                 sortNodes: sortNodes,
                                                 board: board)
                                    }
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
                            scale = getDefaultScale()
                            lastScale = scale
                        }
                    }
                }
                .defaultScrollAnchor(.center)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = getScale(value: lastScale * value)
                        }
                        .onEnded { value in
                            lastScale = scale
                        }
                )
                .readSize { size in
                    currentSize = size
                    scale = getScale(value: lastScale)
                    lastScale = scale
                }
            }
            else {
                let width = NodeView.width
                let spacing = NodeView.vStackSpace
                let adaptiveColumn = [GridItem(.adaptive(minimum: width, maximum: width), spacing: spacing)]
                
                ScrollView(showsIndicators: true) {
                    LazyVGrid(columns: adaptiveColumn, spacing: spacing) {
                        ForEach(sortedNodes, id: \.id) { node in
                            if node.children.count > 0 || node.imageName != "" {
                                NodeCardView(node: node)
                            }
                        }
                    }
                    .padding(spacing)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear{
            sortNodes()
        }
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                Button(action: {
                    onBack()
                }) {
                    Image(systemName: "house")
                }
                
                Text(board.title)
                    .font(.headline)
                
                Button(action: {
                    board.toggleView()
                }) {
                    let image = board.isFlashCardView ? "rectangle.grid.2x2.fill" : "rectangle.grid.2x2"
                    Image(systemName: image)
                }
            }
            
            ToolbarItemGroup(placement: .primaryAction) {
                Spacer()
                if (!board.isFlashCardView)
                {
                    Button {
                        let positionX = BoardView.boardWidth / 2
                        let positionY = BoardView.boardHeight / 2 - NodeView.snapY
                        let _ = createNode(positionX: positionX, positionY: positionY)
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
        }
    }
    
    private func sortNodes() {
        let nodes = board.nodes
        var sorted = [NodeData]()
        var queue = nodes.filter { $0.parent == nil }
        var queueNested = [NodeData]()
        
        while !queue.isEmpty || !queueNested.isEmpty {
            if queueNested.isEmpty {
                let node = queue.removeFirst()
                sorted.append(node)
                
                let children = node.children
                queueNested.append(contentsOf: children)
            } else {
                let node = queueNested.removeFirst()
                sorted.append(node)
                
                let children = nodes.filter { $0.parent == node }
                queueNested.append(contentsOf: children)
            }
        }
        
        sortedNodes = sorted
    }
    
    private func getDefaultScale() -> CGFloat {
        let size = currentSize
        let minEdgeLength = min(size.width, size.height)
        let defaultScale = minEdgeLength / (BoardView.boxSize * 5)
        return getScale(value: defaultScale)
    }
    
    private func getScale(value: CGFloat) -> CGFloat {
        let size = currentSize
        let boardAspectRatio = BoardView.boardWidth / BoardView.boardHeight
        let windowAspectRatio = size.width / size.height
        let minEdgeLength = min(size.width, size.height)
        let maxScale = minEdgeLength / BoardView.boxSize
        
        if boardAspectRatio > windowAspectRatio {
            let minScale = size.width / (BoardView.boardWidth * 1.0)
            let newScale = value.clamped(to: minScale...maxScale)
            return newScale
        } else {
            let minScale = size.height / (BoardView.boardHeight * 1.0)
            let newScale = value.clamped(to: minScale...maxScale)
            return newScale
        }
    }
    
    private func createNode(parent: NodeData? = nil, positionX: CGFloat = 0, positionY: CGFloat = 0) {
        let newNode = NodeData(title: "", positionX: Double(positionX), positionY: Double(positionY))
        
        insertNodeData(newNode)
        board.nodes.append(newNode)
        
        parent?.addChild(newNode)
        
        sortNodes()
    }
    
    private func deleteNode(_ nodeData: NodeData) -> Bool {
        if let index = board.nodes.firstIndex(of: nodeData) {
            deleteNodeData(nodeData)
            board.nodes.remove(at: index)
            
            sortNodes()
            
            return true
        }
        
        return false
    }
    
    private func clearBoard() {
        if board.title != "main"
        {
            for nodeData in board.nodes {
                deleteNodeData(nodeData)
            }
            
            board.nodes.removeAll()
            
            sortNodes()
        }
    }
    
    public func insertNodeData(_ nodeData: NodeData) {
        context.insert(nodeData)
    }
    
    public func deleteNodeData(_ nodeData: NodeData) {
        FileHelper.deleteImage(filename: nodeData.imageName)
        context.delete(nodeData)
    }
}
