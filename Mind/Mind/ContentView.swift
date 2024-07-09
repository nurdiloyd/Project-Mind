import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var showBoardPage: Bool = false
    
    var body: some View {
        Group {
            if showBoardPage {
                BoardView()
            } else {
                EntranceView(onStart: {
                    showBoardPage = true
                })
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [NodeData.self])
}
