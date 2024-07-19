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
                .shadow(color: LCConstants.lightColor, radius: shadowRadius, x: -offset, y: -offset)
                .shadow(color: LCConstants.shadowColor, radius: shadowRadius, x: offset, y: offset)
            
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
                .padding(22.5)
                .frame(minWidth: 300, minHeight: 40)
            }
            .frame(minHeight: 85, maxHeight: 280)
            .frame(width: 260)
            .LCContainer(radius: 15, level: 1)
            
            Spacer(minLength: 20)
        }
        .frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
        .background(LCConstants.getColor(0))
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
