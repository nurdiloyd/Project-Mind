import SwiftUI
import SwiftData

struct EntranceView: View {
    @Environment(\.modelContext) private var context
    @Query private var boards: [BoardData]
    
    var openBoard: (BoardData) -> Void
    public static let padding: CGFloat = 8
    public static let radius = LCConstants.cornerRadius
    
    var body: some View {
        VStack(spacing: 40) {
            Image("Image")
                .resizable()
                .frame(width: 100, height: 100)
                .LCContainer(smooth: 7, radius: LCConstants.cornerRadius * 2)
            
            ScrollView([.vertical], showsIndicators: false) {
                VStack(spacing: EntranceView.padding) {
                    if boards.count > 0 {
                        ForEach(boards, id: \.id) { board in
                            BoardCardView(board: board,
                                          openBoard: openBoard,
                                          deleteBoard: deleteBoard)
                        }
                    } else {
                        Text("Create a board")
                            .frame(width: BoardCardView.width, height: BoardCardView.height)
                            .LCContainer(radius: BoardCardView.radius, level: 2)
                    }
                }
                .padding(EntranceView.padding)
            }
            .frame(width: BoardCardView.width + EntranceView.padding * 2)
            .frame(minHeight: (BoardCardView.height + EntranceView.padding) * 1 + EntranceView.padding, maxHeight: (BoardCardView.height + EntranceView.padding) * 5 + EntranceView.padding)
            .scrollDisabled(boards.count < 2)
            .LCContainer(smooth: 7, radius: EntranceView.radius, level: 1)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LCConstants.getColor(0))
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: createNewBoard) {
                    Image(systemName: "plus.circle")
                }
                
                Button(action: deleteAllBoards) {
                    Image(systemName: "trash")
                        .foregroundStyle(Color(NSColor.systemRed))
                }

                Button(action: exportDatabase) {
                    Image(systemName: "square.and.arrow.up")
                }
                /*
                Button(action: importDatabase) {
                    Image(systemName: "square.and.arrow.down")
                }
 */
            }
        }
    }
    
    private func createNewBoard() {
        let newBoard = BoardData(title: "New Board")
        insertBoardData(newBoard)
    }
    
    private func deleteAllBoards() {
        for board in boards {
            deleteBoard(board)
        }
    }
    
    private func deleteBoard(_ board: BoardData) {
        if board.title != "main"
        {
            for node in board.nodes {
                deleteNodeData(node)
            }
            
            board.nodes.removeAll()
            
            deleteBoardData(board)
        }
    }
    
    public func deleteNodeData(_ node: NodeData) {
        FileHelper.deleteImage(filename: node.imageName)
        context.delete(node)
    }
    
    public func insertBoardData(_ boardData: BoardData) {
        context.insert(boardData)
    }

    public func deleteBoardData(_ boardData: BoardData) {
        context.delete(boardData)
    }
    
    private func exportDatabase() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Select Directory to Save Board Data"
        openPanel.message = "Choose a directory to save your boards data"
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        
        openPanel.begin { response in
            if response == .OK, let directoryURL = openPanel.url {
                let folderName = "BoardDataExport"
                let folderURL = directoryURL.appendingPathComponent(folderName)
                
                do {
                    try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                    
                    for board in boards {
                        let fileURL = folderURL.appendingPathComponent("board_\(board.title).json")
                        do {
                            let jsonData = try JSONEncoder().encode(board)
                            try jsonData.write(to: fileURL)
                            print("Database exported to \(fileURL.path)")
                        } catch {
                            print("Failed to export database: \(error.localizedDescription)")
                        }
                    }
                } catch {
                    print("Failed to create directory: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func importDatabase() {
        /*
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["json"]
        panel.begin { response in
            if response == .OK, let url = panel.url {
                do {
                    let jsonData = try Data(contentsOf: url)
                    let importedBoard = try JSONDecoder().decode(BoardData.self, from: jsonData)
                    let newBoard = BoardData(boardData: importedBoard)
                    print("aaa")
                    insertBoardData(newBoard)
                    print("bbb")
                    let nodes = newBoard.nodes
                    print("ccc")
                    let nodeDictionary = Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, $0) })
                    for node in nodes {
                        if let parentID = node.parentID, let parentNode = nodeDictionary[parentID] {
                            node.parent = parentNode
                        }
                    }
                    print("Database imported successfully")
                } catch {
                    print("Failed to import database: \(error.localizedDescription)")
                }
            }
        }
        */
    }
}
