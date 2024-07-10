import SwiftUI
import SwiftData

struct EntranceView: View {
    @Environment(\.modelContext) private var context
    @Query private var boards: [BoardData]
    
    var openBoard: (BoardData) -> Void
    
    var body: some View {
        VStack {
            Image(systemName: "sun.max")
                .resizable()
                .frame(width: 100, height: 100)
            
            if boards.count > 0 {
                ForEach(boards, id: \.id) { board in
                    Button(action: {
                        openBoard(board)
                    }) {
                        Text(board.title)
                            .font(.title)
                            .padding()
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                Text("Please select or create a board.")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .safeAreaPadding(.all)
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
    
    private func createNewBoard() {
        let newBoard = BoardData(title: "New Board")
        insertBoard(newBoard)
        saveContext()
    }
    
    private func deleteAllBoards() {
        for board in boards {
            deleteBoard(board)
        }
        
        saveContext()
    }
    
    public func insertBoard(_ board: BoardData) {
        context.insert(board)
    }

    public func deleteBoard(_ board: BoardData) {
        context.delete(board)
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
