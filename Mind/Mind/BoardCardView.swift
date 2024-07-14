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
        HStack {            
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
                    .onSubmit {
                        isEditing = false
                        setTitle(board, inputText)
                    }
                    .multilineTextAlignment(.center)
                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(width: 120, height: 40)
                }
                else {
                    Text("\(board.title)")
                        .font(.title)
                        .frame(width: 120, height: 40)
                }
            }
            
            Button(action: {
                inputText = board.title
                isEditing = true
                isFocus.toggle()
            }) {
                Image(systemName: "square.and.pencil")
                    .bold()
            }
            .tint(Color.white)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Button(action: {
                withAnimation {
                    isDeleting = true
                }
                
                deleteBoard(board)
            }) {
                Image(systemName: "minus")
                    .bold()
            }
            .tint(Color.red)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(3)
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
