import SwiftUI
import PhotosUI

struct NodeContainerView: View {
    let node: NodeData
    public var createNode: (String, CGFloat, CGFloat, NodeData) -> Void
    public var deleteNode: (NodeData) -> Bool
    public var saveContext: () -> Void
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: NSImage? = nil
    @State private var hasImage: Bool = false
    @State private var isHovering: Bool = false
    @State private var isDeleting: Bool = false
    @State private var isPickerPresenting: Bool = false
    private let containerWidth: CGFloat = 150
    private let stackSpace: CGFloat = 8

    var body: some View {
        ZStack {
            NodeView(
                node: node,
                image: $selectedImage,
                setTitle: setTitle
            )
            .onChange(of: selectedItem) { _, newItem in
                loadImage(photoPickerItem: newItem)
            }
            .overlay{
                if (isHovering || isPickerPresenting)
                {
                    let topLeft = CGPoint(x:-containerWidth / 2, y:-node.containerHeight / 2)
                    let symbolSize = 10.0
                    
                    Button(action: {
                        deleteThisNode()
                    }) {
                        Image(systemName: "minus")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: symbolSize, height: symbolSize)
                            .clipped()
                            .contentShape(Rectangle())
                            .multilineTextAlignment(.center)
                            .bold()
                    }
                    .tint(.red)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.mini)
                    .clipShape(Circle())
                    .offset(x:topLeft.x, y:topLeft.y)
                    
                    Button(action: {
                        isPickerPresenting.toggle()
                    }) {
                        Image(systemName: "photo.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: symbolSize, height: symbolSize)
                            .clipped()
                            .contentShape(Rectangle())
                            .multilineTextAlignment(.center)
                            .bold()
                    }
                    .tint(.green)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.mini)
                    .clipShape(Circle())
                    .offset(x:topLeft.x, y:topLeft.y + 30)
                    .photosPicker(isPresented: $isPickerPresenting,
                                  selection: $selectedItem,
                                  matching: .images,
                                  photoLibrary: .shared())

                    if hasImage {
                        Button(action: {
                            deleteImage()
                            hasImage = false
                        }) {
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: symbolSize, height: symbolSize)
                                .clipped()
                                .contentShape(Rectangle())
                                .multilineTextAlignment(.center)
                                .bold()
                        }
                        .tint(.orange)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.mini)
                        .clipShape(Circle())
                        .offset(x:topLeft.x, y:topLeft.y + 45)
                    }
                    
                    Button(action: {
                        createChildNode()
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: symbolSize, height: symbolSize)
                            .clipped()
                            .contentShape(Rectangle())
                            .multilineTextAlignment(.center)
                            .bold()
                    }
                    .tint(.blue)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.mini)
                    .clipShape(Circle())
                    .offset(x:-topLeft.x, y:topLeft.y + 15)
                }
            }
        }
        .onHover { hovering in
            withAnimation {
                isHovering = hovering
            }
        }
        .frame(width: containerWidth)
        //.scaleEffect(isDeleting ? 0.1 : 1.0)
        .opacity(isDeleting ? 0.0 : 1.0)
        .animation(.spring(duration: 0.3), value: isDeleting)
        .onAppear {
            loadNode()
        }
        .readSize { newSize in
            node.containerHeight = newSize.height
            if node.parent != nil
            {
                withAnimation {
                    rearrangePositionY(node.parent ?? node)
                    saveContext()
                }
            }
        }
        .position(CGPoint(x: CGFloat(node.globalPositionX), y: CGFloat(node.globalPositionY)))
        .gesture(
            DragGesture()
                .onChanged { value in
                    let delta = value.translation
                    withAnimation {
                        moveNode(node, deltaX: delta.width, deltaY: delta.height)
                    }
                }
                .onEnded { value in
                    if node.parent != nil
                    {
                        withAnimation {
                            setPosition(node, positionX: node.lastPositionX, positionY: node.lastPositionY)
                        }
                    }
                    else
                    {
                        snapToGrid(node)
                        updateLastPosition(node)
                        saveContext()
                    }
                }
        )
    }
    
    private func snapToGrid(_ node: NodeData)
    {
        var positionX = node.localPositionX
        var positionY = node.localPositionY
        positionX = (positionX / (containerWidth + stackSpace)).rounded() * (containerWidth + stackSpace)
        positionY = (positionY / 50).rounded() * 50

        setPosition(node, positionX: positionX, positionY: positionY)
    }
    
    private func setTitle(title: String) {
        if !title.isEmptyOrWithWhiteSpace {
            node.title = title
            saveContext()
        }
    }
    
    private func moveNode(_ node: NodeData, deltaX: Double, deltaY: Double) {
        let newX = node.lastPositionX + deltaX
        let newY = node.lastPositionY + deltaY

        setPosition(node, positionX: newX, positionY: newY)
        snapToGrid(node)
    }

    private func setPosition(_ node: NodeData, positionX: Double, positionY: Double) {
        let minX = containerWidth / 2 + (node.parent != nil ? (node.parent!.localPositionX + containerWidth / 2 + 10) : 0)
        let maxX = Double(BoardView.boardSize - containerWidth / 2)
        
        let minY = node.containerHeight / 2
        let maxY = Double(BoardView.boardSize - node.containerHeight / 2)
        
        node.localPositionX = positionX//.clamped(to: minX...maxX)
        node.localPositionY = positionY//.clamped(to: minY...maxY)
    }
    
    private func updateLastPosition(_ node: NodeData) {
        node.lastPositionX = node.localPositionX
        node.lastPositionY = node.localPositionY
    }
    
    private func loadNode() {
        if node.imageName != nil && node.imageName != "" {
            if let imageData = FileHelper.loadImageFromFile(filename: node.imageName ?? "") {
                let nsImage = NSImage(data: imageData)
                self.selectedImage = nsImage
                print("Image loaded successfully")
            } else {
                print("No image found for filename: \(node.imageName ?? "")")
            }
        }
        
        hasImage = node.imageName != ""
    }

    private func loadImage(photoPickerItem: PhotosPickerItem?) {
        if let item = photoPickerItem {
            Task {
                if let imageData = try? await item.loadTransferable(type: Data.self) {
                    if let nsImage = NSImage(data: imageData) {
                        let imageName = "image_\(UUID().uuidString).png"
                        selectedImage = nsImage
                        node.imageName = imageName
                        FileHelper.saveImageToFile(data: imageData, filename: imageName)
                    }
                    
                    saveContext()
                    hasImage = true
                }
            }
        }
    }
    
    private func deleteImage() {
        FileHelper.deleteSavedImage(filename: node.imageName ?? "")
        selectedImage = nil
        node.imageName = ""
        
        saveContext()
    }
    
    private func deleteThisNode() {
        withAnimation {
            isDeleting = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let parent = node.parent
            let children = node.children
            let posX = node.globalPositionX
            let posY = node.globalPositionY
            let isDeleted = deleteNode(node)
            
            if isDeleted
            {
                for child in children {
                    child.localPositionX = child.localPositionX + posX
                    child.localPositionY = child.localPositionY + posY
                    updateLastPosition(child)
                }
                
                withAnimation {
                    if parent != nil
                    {
                        rearrangePositionY(parent ?? node)
                    }
                    
                    for child in children {
                        snapToGrid(child)
                        updateLastPosition(child)
                    }
                    
                    saveContext()
                }
            }
            else {
                isDeleting = false
            }
        }
    }
    
    private func createChildNode() {
        createNode("Title", 0, 0, node)
        
        withAnimation {
            rearrangePositionY(node)
        }
    }
    
    private func rearrangePositionY(_ node: NodeData)
    {
        let sortedChildren = node.children.sorted(by: { $0.order > $1.order })
        
        var totalHeight = 0.0
        for child in sortedChildren {
            totalHeight += child.containerHeight
        }
        
        var currentY = totalHeight / 2
        for child in sortedChildren {
            child.localPositionX = containerWidth + stackSpace
            child.localPositionY = currentY - child.containerHeight / 2
            currentY -= child.containerHeight
            updateLastPosition(child)
        }
    }
}
