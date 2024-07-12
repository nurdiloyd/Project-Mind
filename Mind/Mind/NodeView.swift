import SwiftUI

struct NodeView: View {
    let node: NodeData
    @Binding var image: NSImage?
    var setTitle: (String) -> Void
    
    @State private var isEditing: Bool = false
    @FocusState private var isFocus: Bool
    @State var inputText: String = ""

    var haveImage: Bool {
        return image != nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isEditing
            {
                TextField("Node Title", text: $inputText, onEditingChanged: { isStart in
                        if !isStart
                        {
                            isEditing = false
                            setTitle(inputText)
                        }
                    })
                    .focused($isFocus)
                    .onSubmit {
                        isEditing = false
                        setTitle(inputText)
                    }
                    .foregroundColor(Color(NSColor.windowFrameTextColor))
                    .multilineTextAlignment(.center)
                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(height: NodeContainerView.titleHeight)
            }
            else {
                Text("\(node.title)")
                    .foregroundColor(Color(NSColor.windowFrameTextColor))
                    .font(.headline)
                    .frame(height: NodeContainerView.titleHeight)
                    .onTapGesture(count: 1) {
                        inputText = node.title
                        isEditing = true
                        isFocus.toggle()
                    }
            }
            
            if let customImage = image {
                Image(nsImage: customImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: NodeContainerView.imageHeight, height: NodeContainerView.imageHeight)
                    .clipped()
                    .contentShape(Rectangle())
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 11))
        .shadow(radius: 5)
        .readSize { si in
            print(si)
        }
    }
}
