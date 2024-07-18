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
    @State private var isDeleting: Bool = false
    @State private var onCreation: Bool = false
    
    var body: some View {
        HStack (spacing: 5) {
            Button(action: {
                openBoard(board)
            }) {
                if isEditing
                {
                    TextField("Board Title", text: $inputText, onEditingChanged: { isStart in
                        if !isStart && !onCreation
                        {
                            isEditing = false
                            setTitle(board, inputText)
                        }
                        
                        onCreation = false
                    })
                    .font(.title2)
                    .focused($isFocus)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .nkButton(smooth: 5, radius: 14)
                    .onSubmit {
                        isEditing = false
                        setTitle(board, inputText)
                    }
                }
                else {
                    Text("\(board.title)")
                        .font(.title)
                        .padding(8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .nkButton(smooth: 2, radius: 14)
                }
            }
            .buttonStyle(.plain)
            
            Button(action: {
                inputText = board.title
                isEditing = true
                isFocus.toggle()
            }) {
                Image(systemName: "square.and.pencil")
                    .nkMiniButton(width: 30, height: 30, padding: 8, smooth: 2, radius: 14)
            }
            .buttonStyle(.plain)
            
            Button(action: {
                withAnimation {
                    isDeleting = true
                }
                
                deleteBoard(board)
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
                isEditing = true
                isFocus.toggle()
            }
        }
    }
}
