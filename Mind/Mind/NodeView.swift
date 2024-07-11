import SwiftUI

struct NodeView: View {
    let node: NodeData
    @Binding var image: NSImage?
    var setTitle: (String) -> Void
    
    @State private var isEditing: Bool = false
    @FocusState private var isFocus: Bool
    @State var inputText: String = ""

    public static let titleHeight: CGFloat = 30
    public let imageHeight: CGFloat = 150
    var totalHeight: CGFloat {
        return NodeView.titleHeight + (haveImage ? imageHeight : 0)
    }
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
                    .frame(height: NodeView.titleHeight)
            }
            else {
                Text("\(node.order) \(node.title)")
                    .foregroundColor(Color(NSColor.windowFrameTextColor))
                    .font(.headline)
                    .frame(height: NodeView.titleHeight)
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
                    .frame(width: imageHeight, height: imageHeight)
                    .clipped()
                    .contentShape(Rectangle())
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(11)
        .shadow(radius: 8)
    }
}
