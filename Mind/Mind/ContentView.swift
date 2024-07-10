import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var showBoardPage: Bool = false
    @State private var selectedBoard: BoardData? = nil
    
    var body: some View {
        Group {
            if showBoardPage, let board = selectedBoard {
                BoardView(board: board)
            } else {
                EntranceView(openBoard: { board in
                    selectedBoard = board
                    showBoardPage = true
                })
            }
        }
    }
}
