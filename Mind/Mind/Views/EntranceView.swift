import SwiftUI
import SwiftData

struct EntranceView: View {
    @Environment(\.modelContext) private var context
    @Query private var boards: [BoardData]
    
    var openBoard: (BoardData) -> Void
    
    var body: some View {
        VStack {
            Spacer(minLength: 100)

            Image("Image")
                .resizable()
                .frame(width: 100, height: 100)
                .shadow(color: Color(red: 204/255, green: 222/255, blue: 227/255), radius: 20, y: 5)
            
            Spacer(minLength: 80)
            
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
                        Button(action: {
                            createNewBoard()
                        }){
                            Text("Create a board")
                                .frame(width: 215, height: 40)
                                .nkButton(smooth: 5, radius: 14)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(22.5)
                .frame(minWidth: 300, minHeight: 40)
            }
            .frame(minHeight: 40, maxHeight: 280)
            .frame(width: 260)
            //.padding(1)
            .nkButton(isInner: false, smooth: 3, radius: 28.25)
            
            Spacer(minLength: 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 250/255, green: 250/255, blue: 250/255))
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
}
