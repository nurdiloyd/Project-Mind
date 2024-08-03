import SwiftUI
import PhotosUI

struct BoardCardView: View {
    public let board: BoardData
    public var openBoard: (BoardData) -> Void
    public var deleteBoard: (BoardData) -> Void
    
    @FocusState private var isFocus: Bool
    @State private var isEditing: Bool = false
    @State var inputText: String = ""
    @State private var onCreation: Bool = false
    @State private var isInner: Bool = true
    
    @State public static var radius: CGFloat =  EntranceView.radius - EntranceView.padding / 2.0
    @State public static var padding: CGFloat = EntranceView.padding / 2.0
    @State public static var width: CGFloat = 210
    @State public static var height: CGFloat = 40
    
    var body: some View {
        HStack (spacing: BoardCardView.padding) {
            ZStack() {
                if isEditing
                {
                    TextField("Board Title", text: $inputText, onEditingChanged: { isStart in
                        if !isStart && !onCreation
                        {
                            setIsEditing(false)
                            setTitle(title: inputText)
                        }
                        
                        onCreation = false
                    })
                    .font(.title2)
                    .focused($isFocus)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(PlainTextFieldStyle())
                }
                else {
                    Text("\(board.title)")
                        .font(.title)
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .frame(height: BoardCardView.height)
            .LCContainer(smooth: isInner ? 4 : 8, radius: BoardCardView.radius, level: 2)
            .onTapGesture(count: 1, perform: {
                withAnimation(.interpolatingSpring(stiffness: 1000, damping: 30)) {
                    isInner = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    openBoard(board)
                }
            })
            .onHover(perform: { hover in
                withAnimation(.interpolatingSpring(stiffness: 200, damping: 20)) {
                    isInner = !hover
                }
            })
            
            VStack(spacing: BoardCardView.padding) {
                let width = 30.0
                let height = (BoardCardView.height - BoardCardView.padding) / 2
                Button(action: {
                    inputText = board.title
                    setIsEditing(true)
                    isFocus.toggle()
                }) {
                    Image(systemName: "square.and.pencil")
                        .LCButton(width: width, height: height, padding: 3, level: 2, radius: BoardCardView.radius)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    deleteBoard(board)
                }) {
                    Image(systemName: "minus")
                        .LCButton(width: width, height: height, level: 2, radius: BoardCardView.radius)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(width: BoardCardView.width, height: BoardCardView.height)
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
        isEditing = editing
    }
    
    private func setTitle(title: String) {
        board.setTitle(title: title)
    }
}
