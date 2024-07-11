import SwiftUI
import PhotosUI

struct BoardCardView: View {
    public let board: BoardData
    public var openBoard: (BoardData) -> Void
    public var deleteBoard: (BoardData) -> Void
    public var setTitle: (BoardData, String) -> Void
    
    @State private var isEditing: Bool = false
    @State var inputText: String = ""
    @State private var isHovering: Bool = false
    @State private var isDeleting: Bool = false
    
    var body: some View {
        ZStack() {
            Button(action: {
                openBoard(board)
            }) {
                if isEditing {
                    TextField("Node Title", text: $inputText, onCommit: {
                        isEditing = false
                        setTitle(board, inputText)
                    })
                    .foregroundColor(Color(NSColor.windowFrameTextColor))
                    .multilineTextAlignment(.center)
                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(height: NodeView.titleHeight)
                } else {
                    Text("\(board.title)")
                        .foregroundColor(Color(NSColor.windowFrameTextColor))
                        .font(.title)
                        .frame(height: NodeView.titleHeight)
                        .onTapGesture(count: 1) {
                            inputText = board.title
                            isEditing = true
                        }
                }
            }
            .buttonStyle(.bordered)
            
            Button(action: {
                withAnimation {
                    isDeleting = true
                }
                
                deleteBoard(board)
            }) {
                Image(systemName: "minus")
                    .bold()
                    .frame(maxHeight: .infinity)
            }
            .tint(Color.red)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .position(x: 140, y: 15)
            .opacity(isHovering ? 1.0 : 0.0)
            .animation(.spring(duration: 0.5), value: isHovering)
            
        }
        .onHover { hovering in
            withAnimation {
                isHovering = hovering
            }
        }
        //.scaleEffect(isDeleting ? 0.1 : 1.0)
        //.opacity(isDeleting ? 0.0 : 1.0)
        
    }
}
