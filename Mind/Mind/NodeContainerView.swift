import SwiftUI
import PhotosUI

struct NodeContainerView: View {
    @Environment(\.modelContext) private var context
    let node: NodeData
    
    @State private var selectedImage: NSImage? = nil
    @State private var hasImage: Bool = false
    @State private var isHovering: Bool = false
    @State private var isDeleting: Bool = false
    @State var containerHeight: CGFloat = 0
    let containerWidth: CGFloat = 150
    let stackSpace: CGFloat = 8

    var body: some View {
        HStack {
            VStack(spacing: stackSpace) {
                NodeContainerTopView(
                    importImage: importImage,
                    deleteImage: deleteImage,
                    addChildNode: addChildNode,
                    hasImage: $hasImage
                )
                
                NodeView(
                    node: node,
                    image: $selectedImage,
                    setTitle: setTitle
                )
                
                NodeContainerBottomView(
                    buttonAction: deleteNode
                )
            }
            .onHover { hovering in
                withAnimation {
                    isHovering = hovering
                }
            }
            .frame(width: containerWidth)
            .scaleEffect(isDeleting ? 0.1 : 1.0)
            .opacity(isDeleting ? 0.0 : 1.0)
            .animation(.spring(duration: 0.5), value: isDeleting)
            .readSize { newSize in
                containerHeight = newSize.height
                setPosition(node, positionX: node.positionX, positionY: node.positionY)
                updateLastPosition(node)
            }
            
            if node.children.count > 0 {
                VStack(alignment: .leading) {
                    ForEach(node.children, id: \.self) { child in
                        NodeContainerView(node: child)
                    }
                }
            }
        }
        .if(node.parent == nil) {
            $0.position(CGPoint(x: CGFloat(node.positionX), y: CGFloat(node.positionY)))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            withAnimation {
                                let delta = value.translation
                                moveNode(node, deltaX: delta.width, deltaY: delta.height)
                            }
                        }
                        .onEnded { value in
                            updateLastPosition(node)
                            saveContext()
                        }
                )
        }
        .onAppear {
            loadNode()
        }
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
        
        for child in node.children {
            moveNode(child, deltaX: deltaX, deltaY: deltaY)
        }
    }

    private func setPosition(_ node: NodeData, positionX: Double, positionY: Double) {
        let minX = containerWidth / 2 + (node.parent != nil ? (node.parent!.positionX + containerWidth / 2 + 10) : 0)
        let maxX = Double(ContentView.boardSize - containerWidth / 2)
        
        let minY = containerHeight / 2
        let maxY = Double(ContentView.boardSize - containerHeight / 2)
        
        node.positionX = positionX.clamped(to: minX...maxX)
        node.positionY = positionY.clamped(to: minY...maxY)
    }
    
    private func updateLastPosition(_ node: NodeData) {
        node.lastPositionX = node.positionX
        node.lastPositionY = node.positionY
        
        for child in node.children {
            updateLastPosition(child)
        }
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
        updateLastPosition(node)
    }

    private func importImage(imageData: Data) {
        if let nsImage = NSImage(data: imageData) {
            let imageName = "image_\(UUID().uuidString).png"
            selectedImage = nsImage
            node.imageName = imageName
            FileHelper.saveImageToFile(data: imageData, filename: imageName)
        }
        
        saveContext()
    }
    
    private func deleteImage() {
        FileHelper.deleteSavedImage(filename: node.imageName ?? "")
        selectedImage = nil
        node.imageName = ""
        
        saveContext()
    }
    
    private func deleteNode() {
        withAnimation {
            isDeleting = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            context.delete(node)
            
            saveContext()
        }
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func addChildNode() {
        withAnimation {
            let newNode = NodeData(
                title: "Title",
                positionX: node.positionX + containerWidth + 10,
                positionY: node.positionY,
                imageName: "",
                parent: node
            )
            
            node.addChild(node: newNode)
            
            context.insert(newNode)
            
            saveContext()
        }
    }
}
