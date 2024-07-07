import SwiftUI
import PhotosUI

struct NodeContainerView: View {
    let node: NodeData
    public var createNode: (String, CGFloat, CGFloat, NodeData) -> Void
    public var deleteNode: (NodeData) -> Void
    public var saveContext: () -> Void
    
    @State private var selectedImage: NSImage? = nil
    @State private var hasImage: Bool = false
    @State private var isHovering: Bool = false
    @State private var isDeleting: Bool = false
    private let containerWidth: CGFloat = 150
    private let stackSpace: CGFloat = 8

    var body: some View {
        VStack(spacing: stackSpace) {
            NodeContainerTopView(
                importImage: importImage,
                deleteImage: deleteImage,
                addChildNode: createChildNode,
                hasImage: $hasImage
            )
            
            NodeView(
                node: node,
                image: $selectedImage,
                setTitle: setTitle
            )
            
            //if (isHovering)
            //{
                NodeContainerBottomView(
                    buttonAction: deleteThisNode
                )
            //}
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
                    moveNode(node, deltaX: delta.width, deltaY: delta.height)
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
                        //snapToGrid()
                        updateLastPosition(node)
                        saveContext()
                    }
                }
        )
    }
    
    private func snapToGrid()
    {
        var positionX = node.localPositionX
        var positionY = node.localPositionY
        positionX = (positionX / containerWidth).rounded() * containerWidth
        positionY = (positionY / 200).rounded() * 200

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
        
    }

    private func setPosition(_ node: NodeData, positionX: Double, positionY: Double) {
        let minX = containerWidth / 2 + (node.parent != nil ? (node.parent!.localPositionX + containerWidth / 2 + 10) : 0)
        let maxX = Double(ContentView.boardSize - containerWidth / 2)
        
        let minY = node.containerHeight / 2
        let maxY = Double(ContentView.boardSize - node.containerHeight / 2)
        
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
    
    private func deleteThisNode() {
        withAnimation {
            isDeleting = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let parent = node.parent
            for child in node.children {
                child.localPositionX = child.globalPositionX
                child.localPositionY = child.globalPositionY
                updateLastPosition(child)
            }
            
            deleteNode(node)

            saveContext()
            if parent != nil
            {
                withAnimation {
                    rearrangePositionY(parent ?? node)
                }
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
        var totalHeight = 0.0
        for child in node.children {
            totalHeight += child.containerHeight
        }
        
        var currentY = totalHeight / 2
        for child in node.children {
            child.localPositionX = containerWidth + stackSpace
            child.localPositionY = currentY - child.containerHeight / 2
            currentY -= child.containerHeight
            updateLastPosition(child)
        }
    }
}
