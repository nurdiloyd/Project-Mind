import SwiftUI
import SwiftData

struct EntranceView: View {
    @Environment(\.modelContext) private var context
    @Query private var boards: [BoardData]
    
    var openBoard: (BoardData) -> Void
    private let padding: CGFloat = 22.5
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer(minLength: 20)
            
            let radius = LCConstants.cornerRadius + padding / 2
            
            Image("Image")
                .resizable()
                .frame(width: 100, height: 100)
                .LCContainer(smooth: 7, radius: radius)
            
            ScrollView([.vertical], showsIndicators: false) {
                VStack{
                    if boards.count > 0 {
                        ForEach(boards, id: \.id) { board in
                            BoardCardView(board: board,
                                          openBoard: openBoard,
                                          deleteBoard:deleteBoard,
                                          setTitle: setTitle)
                        }
                    } else {
                        Text("Create a board")
                            .frame(width: 215, height: 40)
                            .LCContainer(level: 2)
                    }
                }
                .padding(padding)
                .frame(minWidth: 300, minHeight: 40)
            }
            .frame(minHeight: 85, maxHeight: 280)
            .frame(width: 260)
            .LCContainer(smooth: 7, radius: radius, level: 1)
            
            Spacer(minLength: 20)
        }
        .frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
        .background(LCConstants.getColor(0))
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: createNewBoard) {
                    Image(systemName: "plus.circle")
                }
                
                Button(action: deleteAllBoards) {
                    Image(systemName: "trash")
                }
                
                Button(action: exportDatabase) {
                    Image(systemName: "square.and.arrow.up")
                }
                
                Button(action: importDatabase) {
                    Image(systemName: "square.and.arrow.down")
                }
            }
        }
    }
    
    private func setTitle(_ board: BoardData, title: String) {
        if !title.isEmptyOrWithWhiteSpace {
            board.title = title
            saveContext()
        }
    }
    
    private func createNewBoard() {
        let newBoard = BoardData(title: "New Board")
        insertBoardData(newBoard)
        saveContext()
    }
    
    private func deleteAllBoards() {
        for board in boards {
            deleteBoard(board)
        }
    }
    
    private func deleteBoard(_ board: BoardData) {
        for node in board.nodes {
            deleteNodeData(node)
        }
        
        board.nodes.removeAll()
        
        deleteBoardData(board)
        
        saveContext()
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
    
    public func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func exportDatabase() {
        /*
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let exportURL = documentDirectory.appendingPathComponent("ExportedDatabase.json")
        
        do {
            let jsonData = try JSONEncoder().encode(boards[1])
            try jsonData.write(to: exportURL)
            print("Database exported to \(exportURL.path)")
        } catch {
            print("Failed to export database: \(error.localizedDescription)")
        }
         */
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
