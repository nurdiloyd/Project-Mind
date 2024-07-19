import SwiftUI
import PhotosUI

struct BoardCardView: View {
    public let board: BoardData
    public var openBoard: (BoardData) -> Void
    public var deleteBoard: (BoardData) -> Void
    public var setTitle: (BoardData, String) -> Void
    
    @FocusState private var isFocus: Bool
    @State private var isEditing: Bool = false
    @State var inputText: String = ""
    @State private var onCreation: Bool = false
    @State private var isInner: Bool = true
    
    var body: some View {
        HStack (spacing: 5) {
            Button(action: {
                withAnimation(.interpolatingSpring(stiffness: 1000, damping: 30)) {
                    isInner = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    openBoard(board)
                }
            }) {
                if isEditing
                {
                    TextField("Board Title", text: $inputText, onEditingChanged: { isStart in
                        if !isStart && !onCreation
                        {
                            setIsEditing(false)
                            setTitle(board, inputText)
                        }
                        
                        onCreation = false
                    })
                    .font(.title2)
                    .focused($isFocus)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .LCContainer(level: 2)
                    .onSubmit {
                        setIsEditing(false)
                        setTitle(board, inputText)
                    }
                }
                else {
                    Text("\(board.title)")
                        .font(.title)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .LCContainer(level: 2)
                }
            }
            .buttonStyle(.plain)
            .onHover(perform: { hover in
                withAnimation(.interpolatingSpring(stiffness: 200, damping: 20)) {
                    isInner = !hover
                }
            })
            
            Button(action: {
                inputText = board.title
                setIsEditing(true)
                isFocus.toggle()
            }) {
                Image(systemName: "square.and.pencil")
                    .LCButton(width: 30, height: 30, level: 2)
            }
            .buttonStyle(.plain)
            
            Button(action: {
                withAnimation(.interpolatingSpring(stiffness: 500, damping: 30)) {
                    deleteBoard(board)
                }
            }) {
                Image(systemName: "minus")
                    .LCButton(width: 30, height: 30, level: 2)
            }
            .buttonStyle(.plain)
        }
        .frame(width: 215, height: 40)
        .onAppear {
            if !board.isInit {
                board.isInit = true
                onCreation = true
                inputText = board.title
                isEditing = true
                isFocus.toggle()
            }
        }
    }
    
    private func setIsEditing(_ editing: Bool)
    {
        withAnimation(.interpolatingSpring(stiffness: 100, damping: 5)) {
            isEditing = editing
        }
    }
}
