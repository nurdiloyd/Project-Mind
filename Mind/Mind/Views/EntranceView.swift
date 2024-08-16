import SwiftUI
import SwiftData

struct EntranceView: View {
    @Environment(\.modelContext) private var context
    @Query private var boards: [BoardData]
    
    @State private var sortedBoards: [BoardData] = [BoardData]()
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
                    if sortedBoards.count > 0 {
                        ForEach(sortedBoards, id: \.id) { board in
                            BoardCardView(board: board,
                                          openBoard: openBoard,
                                          deleteBoard: deleteBoard,
                                          setTitle:{ title in setBoardTitle(board, title: title)})
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
            .scrollDisabled(sortedBoards.count < 2)
            .LCContainer(smooth: 7, radius: EntranceView.radius, level: 1)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LCConstants.getColor(0))
        .onAppear {
            sortBoards()
        }
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
                Button(action: importDatabase) {
                    Image(systemName: "square.and.arrow.down")
                }
            }
        }
    }
    
    private func setBoardTitle(_ board: BoardData, title: String)
    {
        let trimmedTitle = title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let newTitle = checkDuplicateTitle(board, trimmedTitle, 0)
        
        board.setTitle(title: newTitle)
        sortBoardsWithAnimation()
    }
    
    private func checkDuplicateTitle(_ board: BoardData, _ title: String, _ counter: Int) -> String
    {
        let ss = counter == 0 ? title : "\(title)(\(counter))"
        for otherBoard in boards {
            if otherBoard.id != board.id && otherBoard.title == ss {
                return checkDuplicateTitle(board, title, counter + 1)
            }
        }
        
        return ss
    }
    
    private func sortBoardsWithAnimation() {
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 25)) {
            sortBoards()
        }
    }
    
    private func sortBoards()
    {
        var sorted = [BoardData]()
        var queue = boards.sorted { $0.title < $1.title }
        
        while !queue.isEmpty {
            let board = queue.removeFirst()
            sorted.append(board)
        }
        
        sortedBoards = sorted
        
    }
    private func createNewBoard() {
        let newBoard = BoardData(title: "New Board")
        insertBoardData(newBoard)
        
        sortBoardsWithAnimation()
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
        
        sortBoardsWithAnimation()
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
        let savePanel = NSSavePanel()
        savePanel.title = "Save Board Data"
        savePanel.message = "Choose a location to save your board data"
        savePanel.prompt = "Save"
        savePanel.canCreateDirectories = true
        savePanel.nameFieldLabel = "Folder Name:"
        savePanel.nameFieldStringValue = "Data"
        
        savePanel.begin { response in
            if response == .OK, let directoryURL = savePanel.url {
                let folderURL = directoryURL
                
                do {
                    try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                    
                    for board in boards {
                        let boardId = board.id
                        let boardFileURL = folderURL.appendingPathComponent("board_\(boardId).json")
                        let jsonData = try JSONEncoder().encode(board)
                        try jsonData.write(to: boardFileURL)
                        
                        let imagesFolderURL = folderURL.appendingPathComponent("images_\(boardId)")
                        try FileManager.default.createDirectory(at: imagesFolderURL, withIntermediateDirectories: true, attributes: nil)
                        for node in board.nodes {
                            if !node.imageName.isEmptyOrWithWhiteSpace {
                                let imageName = node.imageName
                                if let imageData = FileHelper.loadImage(filename: imageName) {
                                    let imageFileURL = imagesFolderURL.appendingPathComponent(imageName)
                                    try imageData.write(to: imageFileURL)
                                }
                            }
                        }
                    }
                } catch {
                    print("Failed to export database: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func importDatabase() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Import Board Data"
        openPanel.message = "Choose a directory to import your board data"
        openPanel.prompt = "Import"
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = false
        openPanel.allowsMultipleSelection = false

        var previousBoardIds: [UUID] = []
        for board in boards {
            previousBoardIds.append(board.id)
        }
        
        openPanel.begin { response in
            if response == .OK, let directoryURL = openPanel.url {
                do {
                    let fileManager = FileManager.default
                    let contents = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: [])
                    
                    for contentURL in contents {
                        if contentURL.pathExtension == "json", contentURL.lastPathComponent.hasPrefix("board_") {
                            let jsonData = try Data(contentsOf: contentURL)
                            let board = try JSONDecoder().decode(BoardData.self, from: jsonData)
                            
                            if previousBoardIds.contains(board.id) {
                                continue
                            }
                            
                            let boardId = board.id
                            let imagesFolderURL = directoryURL.appendingPathComponent("images_\(boardId)")
                            if fileManager.fileExists(atPath: imagesFolderURL.path) {
                                let imageFiles = try fileManager.contentsOfDirectory(at: imagesFolderURL, includingPropertiesForKeys: nil, options: [])
                                
                                for imageFile in imageFiles {
                                    let imageName = imageFile.lastPathComponent
                                    let imageData = try Data(contentsOf: imageFile)
                                    FileHelper.saveImage(data: imageData, filename: imageName)
                                }
                            }
                            
                            insertBoardData(board)
                        }
                    }
                    
                    for board in boards {
                        if previousBoardIds.contains(board.id)
                        {
                            continue
                        }
                        
                        for node in board.nodes {
                            if let parentId = node.parentId {
                                for parent in board.nodes {
                                    if parentId == parent.id {
                                        parent.addChild(node)
                                        break
                                    }
                                }
                            }
                        }
                    }
                    
                    sortBoardsWithAnimation()
                } catch {
                    print("Failed to import database: \(error.localizedDescription)")
                }
            }
        }
    }
}
