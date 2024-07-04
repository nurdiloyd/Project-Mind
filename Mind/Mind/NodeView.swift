import SwiftUI

struct NodeView: View {
    @State private var isEditing: Bool = false
    @Binding var customImage: NSImage?
    @ObservedObject var node: NodeEntity
    @State var inputText: String = ""

    public static let titleHeight: CGFloat = 30
    public let imageHeight: CGFloat = 150
    var totalHeight: CGFloat {
        return NodeView.titleHeight + (haveImage ? imageHeight : 0)
    }
    var haveImage: Bool {
        return customImage != nil
    }
    
    var body: some View {
            VStack(spacing: 0) {
                if isEditing {
                    TextField("Node Title", text: $inputText, onCommit: {
                        isEditing = false
                        if !inputText.isEmpty {
                            node.title = inputText
                            saveNode()
                        }
                    })
                    .foregroundColor(Color(NSColor.windowFrameTextColor))
                    .multilineTextAlignment(.center)
                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(height: NodeView.titleHeight)
                } else {
                    Text(node.title ?? "New Node")
                        .foregroundColor(Color(NSColor.windowFrameTextColor))
                        .font(.headline)
                        .frame(height: NodeView.titleHeight)
                        .onTapGesture(count: 1) {
                            inputText = node.title ?? ""
                            isEditing = true
                        }
                }
                
                if let customImage = customImage {
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
    
    private func saveNode() {
        do {
            try node.managedObjectContext?.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct NodeView_Previews: PreviewProvider {
    static var previews: some View {
        NodeView(customImage: .constant(nil), node: NodeEntity(context: PersistenceController.preview.container.viewContext))
    }
}
