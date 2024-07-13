import SwiftUI
import PhotosUI

struct NodeContainerView: View {
    public let node: NodeData
    public var createNode: (String, NodeData) -> Void
    public var deleteNode: (NodeData) -> Bool
    public var saveContext: () -> Void
    
    @State private var inputText: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var image: NSImage? = nil
    @State private var isEditing: Bool = false
    @State private var isHovering: Bool = false
    @State private var isDeleting: Bool = false
    @State private var isPickerPresenting: Bool = false
    @FocusState private var isFocus: Bool
    private var hasImage: Bool { return image != nil}
    
    private static let width: CGFloat = 150
    private static let maxHeight: CGFloat = NodeContainerView.titleHeight + NodeContainerView.imageHeight
    private static let minHeight: CGFloat = NodeContainerView.titleHeight
    private static let titleHeight: CGFloat = 30
    private static let imageHeight: CGFloat = NodeContainerView.width
    private static let countCorrespondsMaxHeight: Int = 5
    private static let hStackSpace: CGFloat = 10
    private static let vStackSpace: CGFloat =
            (NodeContainerView.maxHeight - NodeContainerView.minHeight * CGFloat(NodeContainerView.countCorrespondsMaxHeight))
        / CGFloat(NodeContainerView.countCorrespondsMaxHeight - 1)
    private static let snapX = NodeContainerView.width + NodeContainerView.hStackSpace
    private static let snapY = NodeContainerView.minHeight + NodeContainerView.vStackSpace
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if isEditing
                {
                    TextField("Node Title", text: $inputText, onEditingChanged: { isStart in
                            if !isStart
                            {
                                isEditing = false
                                setTitle(title: inputText)
                            }
                        })
                        .focused($isFocus)
                        .onSubmit {
                            isEditing = false
                            setTitle(title: inputText)
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
            .onChange(of: selectedItem) { _, newItem in
                loadImage(photoPickerItem: newItem)
            }
            .overlay{
                if (isHovering || isPickerPresenting)
                {
                    let topLeft = CGPoint(x:-NodeContainerView.width / 2, y:-node.containerHeight / 2)
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
                    .offset(x:topLeft.x, y:topLeft.y + NodeContainerView.minHeight)
                    .photosPicker(isPresented: $isPickerPresenting,
                                  selection: $selectedItem,
                                  matching: .images,
                                  photoLibrary: .shared())

                    if hasImage {
                        Button(action: {
                            deleteImage()
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
                        .offset(x:topLeft.x, y:topLeft.y + 3 * NodeContainerView.minHeight / 2)
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
                    .offset(x:-topLeft.x, y:topLeft.y + NodeContainerView.minHeight / 2)
                }
            }
        }
        .onHover { hovering in
            withAnimation {
                isHovering = hovering
            }
        }
        .frame(width: NodeContainerView.width)
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
                    rearrangeChildrenPositionY(node.parent ?? node)
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
                    withAnimation {
                        if node.parent != nil
                        {
                            setPosition(node, positionX: node.lastPositionX, positionY: node.lastPositionY)
                        }
                        else
                        {
                            snapToGrid(node)
                            updateLastPosition(node)
                            saveContext()
                        }
                    }
                }
        )
    }
    
    private func snapToGrid(_ node: NodeData) {
        var positionX = node.localPositionX
        var positionY = node.localPositionY
        positionX = (positionX / NodeContainerView.snapX).rounded() * NodeContainerView.snapX
        positionY = (positionY / NodeContainerView.snapY).rounded() * NodeContainerView.snapY

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
        let minX = NodeContainerView.width / 2 + (node.parent != nil ? (node.parent!.localPositionX + NodeContainerView.width / 2 + 10) : 0)
        let maxX = Double(BoardView.boardSize - NodeContainerView.width / 2)
        
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
        if let imageName = node.imageName {
            if imageName.isEmptyOrWithWhiteSpace {
                return
            }
            
            if let imageData = FileHelper.loadImageFromFile(filename: imageName) {
                image = NSImage(data: imageData)
            }
        }
    }

    private func loadImage(photoPickerItem: PhotosPickerItem?) {
        if let item = photoPickerItem {
            Task {
                if let imageData = try? await item.loadTransferable(type: Data.self) {
                    if let nsImage = NSImage(data: imageData) {
                        let imageName = "image_\(UUID().uuidString).png"
                        image = nsImage
                        node.imageName = imageName
                        FileHelper.saveImageToFile(data: imageData, filename: imageName)
                    }
                    
                    saveContext()
                }
            }
        }
    }
    
    private func deleteImage() {
        FileHelper.deleteSavedImage(filename: node.imageName ?? "")
        image = nil
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
                }
                
                withAnimation {
                    if parent != nil
                    {
                        rearrangeChildrenPositionY(parent ?? node)
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
        createNode("Title", node)
        
        withAnimation {
            rearrangeChildrenPositionY(node)
        }
    }
    
    private func rearrangeChildrenPositionY(_ node: NodeData)
    {
        let sortedChildren = node.children.sorted(by: { $0.order > $1.order })
        
        var totalHeight = -NodeContainerView.vStackSpace
        for child in sortedChildren {
            totalHeight += child.containerHeight + NodeContainerView.vStackSpace
        }
        
        var currentY = totalHeight / 2
        for child in sortedChildren {
            child.localPositionX = NodeContainerView.snapX
            child.localPositionY = currentY - child.containerHeight / 2
            currentY -= (child.containerHeight + NodeContainerView.vStackSpace)
            updateLastPosition(child)
        }
    }
}
