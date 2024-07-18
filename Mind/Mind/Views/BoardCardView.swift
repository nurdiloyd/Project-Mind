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
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .nkButton(smooth: 5, radius: 14)
                    .onSubmit {
                        setIsEditing(false)
                        setTitle(board, inputText)
                    }
                }
                else {
                    Text("\(board.title)")
                        .font(.title)
                        .scaleEffect(isInner ? 1.0 : 1.04)
                        .padding(8)
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .nkButton(isInner: isInner, smooth: 2, radius: 14)
                }
            }
            .buttonStyle(.plain)
            .onHover(perform: { hover in
                withAnimation(.interpolatingSpring(stiffness: 160, damping: 15)) {
                    isInner = !hover
                }
            })
            
            Button(action: {
                inputText = board.title
                setIsEditing(true)
                isFocus.toggle()
            }) {
                Image(systemName: "square.and.pencil")
                    .nkMiniButton(width: 30, height: 30, padding: 8, smooth: 2, radius: 14)
            }
            .buttonStyle(.plain)
            
            Button(action: {
                withAnimation(.interpolatingSpring(stiffness: 500, damping: 30)) {
                    deleteBoard(board)
                }
            }) {
                Image(systemName: "minus")
                    .nkMiniButton(width: 30, height: 30, padding: 8, smooth: 2, radius: 14)
            }
            .buttonStyle(.plain)
        }
        .frame(width: 215, height: 40)
        .onAppear {
            if !board.isInit {
                board.isInit = true
                onCreation = true
                inputText = board.title
                setIsEditing(true)
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
