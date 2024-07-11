import SwiftUI
import PhotosUI

struct NodeContainerTopView: View {
    var importImage: (Data) -> Void
    var deleteImage: () -> Void
    var addChildNode: () -> Void
    @State private var selectedImage: PhotosPickerItem? = nil
    @Binding var hasImage: Bool
    public static var height: CGFloat = 30
    @State private var isPickerPresented: Bool = false

    var body: some View {
        HStack {
            Button(action: {
                isPickerPresented = true
            }) {
                Image(systemName: "plus.circle")
                    .bold()
                    .frame(maxHeight: .infinity)
            }
            .photosPicker(isPresented: $isPickerPresented,
                          selection: $selectedImage,
                          matching: .images,
                          photoLibrary: .shared())
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .onChange(of: selectedImage) { _, newItem in
                print("dsdsds")
                if let item = newItem {
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self) {
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
