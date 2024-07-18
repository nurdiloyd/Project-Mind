import SwiftUI
import SwiftData

struct EntranceView: View {
    @Environment(\.modelContext) private var context
    @Query private var boards: [BoardData]
    
    var openBoard: (BoardData) -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer(minLength: 20)

            let smooth: CGFloat = 5
            let offset: CGFloat = smooth
            let shadowRadius: CGFloat = smooth
            
            Image("Image")
                .resizable()
                .frame(width: 100, height: 100)
                .shadow(color: Color(.displayP3, red: 255/255, green: 255/255, blue: 255/255), radius: shadowRadius, x: -offset, y: -offset)
                .shadow(color: Color(.displayP3, red: 204/255, green: 222/255, blue: 227/255), radius: shadowRadius, x: offset, y: offset)
            
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
                            .nkButton(isInner: true, smooth: 2, radius: 14)
                    }
                }
                .padding(22.5)
                .frame(minWidth: 300, minHeight: 40)
            }
            .frame(minHeight: 85, maxHeight: 280)
            .frame(width: 260)
            //.padding(1)
            .nkButton(isInner: false, smooth: 3, radius: 28.25)
            
            Spacer(minLength: 20)
        }
        .frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.displayP3, red: 250/255, green: 250/255, blue: 250/255))
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
