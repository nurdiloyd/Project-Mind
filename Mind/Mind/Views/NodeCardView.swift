import SwiftUI
import PhotosUI

struct NodeCardView: View {
    public let node: NodeData
    
    @State private var isHovering: Bool = false
    @State private var isPickerPresenting: Bool = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var imageLoadingOnLoad: Bool = true
    @State private var image: NSImage? = nil
    private var hasImage: Bool { return image != nil }
    
    var body: some View {
        
            VStack(spacing: 0) {
                if node.cardState == 0 || node.cardState == 2 || node.cardState == 3
                {
                    let noTitle = node.title.isEmptyOrWithWhiteSpace
                    Text("\(noTitle  ? "-" : node.title)")
                        .foregroundColor(LCConstants.textColor)
                        .if(noTitle) {
                            $0.font(.subheadline).italic()
                        }
                        .if(!noTitle) {
                            $0.font(.headline)
                        }
                        .frame(height: NodeView.titleHeight)
                }
                
                if node.cardState == 0 || node.cardState == 1 || node.cardState == 3 {
                    if let img = image {
                        let addBackImage = node.cardState == 1
                        Image(nsImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: NodeView.imageHeight, height: addBackImage ? NodeView.maxHeight : NodeView.imageHeight)
                            .clipped()
                            .contentShape(Rectangle())
                            .if(addBackImage) {
                                $0.blur(radius: 4.0)
                                .overlay {
                                    Image(nsImage: img)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: NodeView.imageHeight, height: NodeView.imageHeight)
                                        .clipped()
                                        .contentShape(Rectangle())
                                }
                            }
                    }
                }
            }
            .frame(width: NodeView.width, height: NodeView.maxHeight)
            .blur(radius: node.cardState == 3  ? 1.0 : 0)
            .LCContainer(level: 3, opacity: 0.8)
            .photosPicker(isPresented: $isPickerPresenting, selection: $selectedItem, matching: .images, photoLibrary: .shared())
            .onChange(of: selectedItem) { _, newItem in
                loadImage(photoPickerItem: newItem)
            }
            .overlay {
                if node.cardState == 3  {
                    Color.black.frame(maxWidth: .infinity, maxHeight: .infinity).opacity(0)
                        .LCContainer(level: 2, opacity: 0.4)

                    let textPadding = 10.0
                    Text(node.contentInfo)
                        .foregroundColor(LCConstants.textColor)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(EdgeInsets(top: 0, leading: textPadding, bottom: 0, trailing: textPadding))
                }
                
            }
        .onHover { hovering in
            withAnimation(.spring(duration:0.5)) {
                isHovering = hovering
            }
        }
        .onAppear { loadNode() }
        .onTapGesture(count: 1) {
               node.toggleCardState()
                if node.cardState == 1 && image == nil {
                    node.toggleCardState()
                    node.toggleCardState()
                }
                
                if node.cardState == 3 && node.children.count == 0 {
                    node.toggleCardState()
                }
                
        }
    }
    @State private var sca: Bool = true
    private func loadNode() {
        if !node.isInit
        {
            node.isInit = true
        }
        
        imageLoadingOnLoad = !node.imageName.isEmptyOrWithWhiteSpace
        if let imageData = FileHelper.loadImage(filename: node.imageName) {
            image = NSImage(data: imageData)
            imageLoadingOnLoad = false
        }
        else
        {
            imageLoadingOnLoad = false
        }
    }
    
    private func loadImage(photoPickerItem: PhotosPickerItem?) {
        guard let item = photoPickerItem else { return }

        Task {
            do {
                if let imageData = try await item.loadTransferable(type: Data.self) {
                    if let originalImage = NSImage(data: imageData) {
                        let resizedImage = originalImage.cropToSquare().resize(to: 400)
                        if let compressedImageData = resizedImage.compressToJPEG() {
                            let imageName = "image_\(UUID().uuidString).jpeg"
                            FileHelper.saveImage(data: compressedImageData, filename: imageName)
                            
                            DispatchQueue.main.async {
                                self.image = NSImage(data: compressedImageData)
                                self.node.imageName = imageName
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func deleteImage() {
        FileHelper.deleteImage(filename: node.imageName)
        image = nil
        node.imageName = ""
    }
}
