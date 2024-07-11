import SwiftUI
import SwiftData

struct EntranceView: View {
    @Environment(\.modelContext) private var context
    @Query private var boards: [BoardData]
    
    var openBoard: (BoardData) -> Void
    
    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            VStack {
                Image(systemName: "sun.max")
                    .resizable()
                    .frame(width: 100, height: 100)
                
                if boards.count > 0 {
                    ForEach(boards, id: \.id) { board in
                        BoardCardView(board: board,
                                      openBoard: openBoard,
                                      deleteBoard:deleteBoard,
                                      setTitle: setTitle)
                    }
                } else {
                    Text("Please select or create a board.")
                }
            }
            .safeAreaPadding(.all)
        }
        .defaultScrollAnchor(.center)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .toolbar {
            ToolbarItem {
                Button {
                    createNewBoard()
                } label: {
                    Image(systemName: "plus.circle")
                }
            }
            
            ToolbarItem {
                Button {
                    deleteAllBoards()
                } label: {
                    Image(systemName: "trash")
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
}
