import SwiftUI
import PhotosUI

struct NodeContainerTopView: View {
    var importImage: (Data) -> Void
    var deleteImage: () -> Void
    var addChildNode: () -> Void
    @State private var selectedItem: PhotosPickerItem? = nil
    @Binding var hasImage: Bool
    public static var height: CGFloat = 30
    
    var body: some View {
        HStack {
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Image(systemName: "plus.circle")
                    .bold()
                    .frame(maxHeight: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .onChange(of: selectedItem) { _, newItem in
                if let newItem = newItem {
                    Task {
                        if let data = try? await newItem.loadTransferable(type: Data.self) {
                            importImage(data)
                            hasImage = true
                        }
                    }
                }
            }
            
            if hasImage {
                Button(action: {
                    deleteImage()
                    hasImage = false
                }) {
                    Image(systemName: "minus")
                        .bold()
                        .frame(maxHeight: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            
            Button(action: {
                addChildNode()
            }) {
                Image(systemName: "plus.square.on.square")
                    .bold()
                    .frame(maxHeight: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .frame(height: NodeContainerTopView.height)
        .shadow(radius: 8)
    }
}

struct NodeContainerTop_Previews: PreviewProvider {
    static var previews: some View {
        NodeContainerTopView(
            importImage: { _ in },
            deleteImage: { },
            addChildNode: { },
            hasImage: .constant(false)
        )
    }
}
