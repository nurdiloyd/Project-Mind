import SwiftUI
import PhotosUI

struct NodeView: View {
    public let node: NodeData
    public var createNode: (String, NodeData) -> Void
    public var deleteNode: (NodeData) -> Bool
    public var saveContext: () -> Void
    
    @FocusState private var isFocus: Bool
    @State private var inputText: String = ""
    @State private var isEditing: Bool = false
    @State private var isHovering: Bool = false
    @State private var isDeleting: Bool = false
    @State private var isPickerPresenting: Bool = false
    @State private var isAddingImage: Bool = false
    @State private var onCreation: Bool = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var image: NSImage? = nil
    private var hasImage: Bool { return image != nil }
    
    private static let width: CGFloat = 150
    public static let minHeight: CGFloat = NodeView.titleHeight
    public static let maxHeight: CGFloat = NodeView.titleHeight + NodeView.imageHeight
    private static let titleHeight: CGFloat = 30
    private static let imageHeight: CGFloat = NodeView.width
    private static let countCorrespondsMaxHeight: Int = 5
    private static let hStackSpace: CGFloat = 10
    private static let vStackSpace: CGFloat = (NodeView.maxHeight - NodeView.minHeight * CGFloat(NodeView.countCorrespondsMaxHeight)) / CGFloat(NodeView.countCorrespondsMaxHeight - 1)
    public static let snapX = NodeView.width + NodeView.hStackSpace
    public static let snapY = NodeView.minHeight + NodeView.vStackSpace
    private let cornerRadius: CGFloat = 11
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if isEditing {
                    TextField("Node Title", text: $inputText, onEditingChanged: { isStart in
                        if !isStart && !onCreation {
                            isEditing = false
                            setTitle(title: inputText)
                        }
                        
                        onCreation = false
                    })
                    .focused($isFocus)
                    .onSubmit {
                        isEditing = false
                        setTitle(title: inputText)
                    }
                    .foregroundColor(Color(NSColor.windowFrameTextColor))
                    .multilineTextAlignment(.center)
                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(height: NodeView.titleHeight)
                } else {
                    Text("\(node.title)")
                        .foregroundColor(Color(NSColor.windowFrameTextColor))
                        .font(.headline)
                        .frame(height: NodeView.titleHeight)
                        .onTapGesture(count: 1) {
                            inputText = node.title
                            isEditing = true
                            isFocus.toggle()
                        }
                }
                
                if let img = image {
                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: NodeView.imageHeight, height: NodeView.imageHeight)
                        .clipped()
                        .contentShape(Rectangle())
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color(NSColor.windowBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(radius: 5) 
            .photosPicker(isPresented: $isPickerPresenting, selection: $selectedItem, matching: .images, photoLibrary: .shared())
            .onChange(of: selectedItem) { _, newItem in
                loadImage(photoPickerItem: newItem)
            }
            .overlay {
                if node.isExpandable {
                    let style = node.isExpanded
                    ? isHovering
                        ? StrokeStyle(lineWidth: 1)
                        : StrokeStyle(lineWidth: 1, dash: [20, 1])
                    : isHovering
                        ? StrokeStyle(lineWidth: 1, dash: [20, 1])
                        : StrokeStyle(lineWidth: 1)
                    let color = node.isExpanded ? Color.gray : Color.blue
                    
                    RoundedRectangle(cornerRadius: cornerRadius).stroke(color, style: style)
                }
                
                if (isHovering || isPickerPresenting) {
                    let topLeft = CGPoint(x: -NodeView.width / 2, y: -node.height / 2)
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
                    .offset(x: topLeft.x, y: topLeft.y)
                    
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
                    .offset(x: topLeft.x, y: topLeft.y + NodeView.minHeight)
                    
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
                        .offset(x: topLeft.x, y: topLeft.y + 3 * NodeView.minHeight / 2)
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
                    .offset(x: -topLeft.x, y: topLeft.y + NodeView.minHeight / 2)
                }
            }
        }
        .onHover { hovering in
            withAnimation {
                isHovering = hovering
            }
        }
        .frame(width: NodeView.width)
        .opacity(isDeleting ? 0.0 : 1.0)
        .animation(.spring(duration: 0.3), value: isDeleting)
        .onAppear {
            if !node.isInit
            {
                node.isInit = true
                onCreation = true
                inputText = node.title
                isEditing = true
                isFocus.toggle()
            }

            if let imageData = FileHelper.loadImage(filename: node.imageName) {
                image = NSImage(data: imageData)
            }
        }
        .readSize { newSize in
            node.height = newSize.height
            withAnimation {
                rearrangeSiblingsPositionY(node)
            }
        }
        .position(CGPoint(x: CGFloat(node.globalPositionX), y: CGFloat(node.globalPositionY)))
        .onTapGesture(count: 1) {
            withAnimation {
                node.isExpanded.toggle()
                rearrangeSiblingsPositionY(node)
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let delta = value.translation
                    moveNode(node, deltaX: delta.width, deltaY: delta.height)
                }
                .onEnded { value in
                    withAnimation(.interpolatingSpring(stiffness: 300, damping: 20)) {
                        if node.parent != nil {
                            setPosition(node, positionX: node.lastPositionX, positionY: node.lastPositionY)
                        } else {
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
        positionX = (positionX / NodeView.snapX).rounded() * NodeView.snapX
        positionY = (positionY / NodeView.snapY).rounded() * NodeView.snapY
        
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
        //let minX = NodeView.width / 2 + (node.parent != nil ? (node.parent!.localPositionX + NodeView.width / 2 + 10) : 0)
        //let maxX = Double(BoardView.boardSize - NodeView.width / 2)
        
        //let minY = node.containerHeight / 2
        //let maxY = Double(BoardView.boardSize - node.containerHeight / 2)
        
        node.localPositionX = positionX//.clamped(to: minX...maxX)
        node.localPositionY = positionY//.clamped(to: minY...maxY)
    }
    
    private func updateLastPosition(_ node: NodeData) {
        node.lastPositionX = node.localPositionX
        node.lastPositionY = node.localPositionY
    }
    
    private func loadImage(photoPickerItem: PhotosPickerItem?) {
        if let item = photoPickerItem {
            Task {
                if let imageData = try? await item.loadTransferable(type: Data.self) {
                    if let resizedImage = NSImage(data: imageData)?.cropToSquare().resize(to: 400) {
                        if let compressedImageData = resizedImage.compressToJPEG() {
                            let imageName = "image_\(UUID().uuidString).jpeg"
                            image = resizedImage
                            node.imageName = imageName
                            FileHelper.saveImage(data: compressedImageData, filename: imageName)
                            saveContext()
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
        
        saveContext()
    }
    
    private func deleteThisNode() {
        withAnimation {
            isDeleting = true
            node.isExpanded = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let parent = node.parent
            let children = node.children
            let posX = node.globalPositionX
            let posY = node.globalPositionY
            let isDeleted = deleteNode(node)
            
            if isDeleted {
                for child in children {
                    child.localPositionX = child.localPositionX + posX
                    child.localPositionY = child.localPositionY + posY
                }
                
                withAnimation {
                    if let prnt = parent {
                        rearrangeChildrenPositionY(prnt)
                        rearrangeSiblingsPositionY(prnt)
                    }
                    
                    for child in children {
                        snapToGrid(child)
                        updateLastPosition(child)
                    }
                    
                    saveContext()
                }
            } else {
                isDeleting = false
            }
        }
    }
    
    private func createChildNode() {
        createNode("Title", node)
        
        withAnimation {
            rearrangeChildrenPositionY(node)
            rearrangeSiblingsPositionY(node)
        }
    }
    
    private func rearrangeChildrenPositionY(_ node: NodeData) {
        let sortedChildren = node.children.sorted(by: { $0.order > $1.order })
        
        var totalHeight = -NodeView.vStackSpace
        for child in sortedChildren {
            totalHeight += child.globalHeight + NodeView.vStackSpace
        }
        
        node.contentHeight = totalHeight
        
        var currentY = totalHeight / 2
        for child in sortedChildren {
            child.localPositionX = NodeView.snapX
            child.localPositionY = currentY - child.globalHeight / 2
            currentY -= (child.globalHeight + NodeView.vStackSpace)
            updateLastPosition(child)
        }
    }
    
    private func rearrangeSiblingsPositionY(_ node: NodeData)
    {
        if let parent = node.parent {
            rearrangeChildrenPositionY(parent)
            rearrangeSiblingsPositionY(parent)
        }
    }
}
