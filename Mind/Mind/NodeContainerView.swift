import SwiftUI
import PhotosUI
import CoreData

struct NodeContainerView: View {
    //@ObservedObject var node: NodeData
    let node: NodeData
    
    @State private var selectedImage: NSImage? = nil
    @State private var hasImage: Bool = false
    @State private var isHovering: Bool = false
    @State private var isDeleting: Bool = false
    @Environment(\.managedObjectContext) private var viewContext

    @State var containerHeight: CGFloat = 0
    let containerWidth: CGFloat = 150
    let stackSpace: CGFloat = 8

    var body: some View {
        HStack {
            VStack(spacing: stackSpace) {
                if isHovering {
                    NodeContainerTopView(
                        importImage: { data in
                            importImage(data: data)
                        },
                        deleteImage: {
                            deleteImage()
                        },
                        addChildNode: {
                            addChildNode()
                        },
                        hasImage: $hasImage
                    )
                    .opacity(isHovering ? 1 : 0)
                    .animation(.easeInOut, value: isHovering)
                }
                
                NodeView(
                    customImage: $selectedImage,
                    node: node
                )
                
                if isHovering {
                    NodeContainerBottomView(
                        buttonAction: {
                            deleteNode()
                        }
                    )
                    .opacity(isHovering ? 1 : 0)
                    .animation(.easeInOut, value: isHovering)
                }
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
            
            if let children = node.children as? Set<NodeData>, children.count > 0 {
                VStack(alignment: .leading) {
                    ForEach(Array(children), id: \.self) { child in
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
                                move(offset: value.translation)
                            }
                        }
                        .onEnded { value in
                            updateLastPosition(node)
                            saveNode()
                        }
                )
        }
        .onAppear {
            loadNode()
            updateLastPosition(node)
        }
    }

    public func move(offset: CGSize) {
        moveNode(node, deltaX: offset.width, deltaY: offset.height)
    }

    private func moveNode(_ node: NodeData, deltaX: Double, deltaY: Double) {
        let newX = node.lastPositionX + deltaX
        let newY = node.lastPositionY + deltaY

        setPosition(node, positionX: newX, positionY: newY)
        if let children = node.children as? Set<NodeData> {
            for child in children {
                moveNode(child, deltaX: deltaX, deltaY: deltaY)
            }
        }
    }

    private func setPosition(_ node: NodeData, positionX: CGFloat, positionY: CGFloat) {
        let minX = containerWidth / 2 +  (node.parent != nil ? (node.parent!.positionX + containerWidth / 2 + 10) : 0)
        let maxX = Double(ContentView.boardSize - containerWidth / 2)
        let minY = containerHeight / 2
        let maxY = Double(ContentView.boardSize - containerHeight / 2)
        node.positionX = positionX.clamped(to: minX...maxX)
        node.positionY = positionY.clamped(to: minY...maxY)
    }
    
    private func loadNode() {
        if node.imageName != nil && node.imageName != "" {
            if let savedImageData = FileHelper.loadImageFromFile(filename: node.imageName ?? "") {
                self.selectedImage = NSImage(data: savedImageData)
                print("Image loaded successfully")
            } else {
                print("No image found for filename: \(node.imageName ?? "")")
            }
        }
        hasImage = node.imageName != ""
        updateLastPosition(node)
    }

    private func importImage(data: Data) {
        if let nsImage = NSImage(data: data) {
            let imageName = "image_\(UUID().uuidString).png"
            selectedImage = nsImage
            node.imageName = imageName
            FileHelper.saveImageToFile(data: data, filename: imageName)
        }
        
        saveNode()
    }
    
    private func deleteImage() {
        selectedImage = nil
        FileHelper.deleteSavedImage(filename: node.imageName ?? "")
        node.imageName = ""
        
        saveNode()
    }
    
    private func saveNode() {
        /*
        do {
            try node.managedObjectContext?.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }*/
    }

    private func deleteNode() {
        withAnimation {
            isDeleting = true
        }
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewContext.delete(node)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }*/
    }

    private func addChildNode() {
        /*
        withAnimation {
            let newChildNode = NodeEntity(context: viewContext)
            newChildNode.id = UUID()
            newChildNode.title = "Child Node"
            newChildNode.positionX = node.positionX + containerWidth + 10
            newChildNode.positionY = node.positionY
            newChildNode.imageName = ""
            node.addToChildren(newChildNode)
            newChildNode.parent = node
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }*/
    }
    
    private func updateLastPosition(_ node: NodeData) {
        node.lastPositionX = node.positionX
        node.lastPositionY = node.positionY
        if let children = node.children as? Set<NodeData> {
            for child in children {
                updateLastPosition(child)
            }
        }
    }
}


extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        } else {
            self
        }
    }
}
