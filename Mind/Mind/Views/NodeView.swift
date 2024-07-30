import SwiftUI
import PhotosUI

struct NodeView: View {
    public let node: NodeData
    public var createNode: (String, NodeData) -> Void
    public var deleteNode: (NodeData) -> Bool
    
    @State private var gptService = GPTService()
    @FocusState private var isFocus: Bool
    @State private var inputText: String = ""
    @State private var isEditing: Bool = false
    @State private var isDragging: Bool = false
    @State private var isHovering: Bool = false
    @State private var isHoveringText: Bool = false
    @State private var isDeleting: Bool = false
    @State private var isPickerPresenting: Bool = false
    @State private var isAddingImage: Bool = false
    @State private var onCreation: Bool = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var image: NSImage? = nil
    private var hasImage: Bool { return image != nil }
    
    public static let width: CGFloat = 150
    public static let minHeight: CGFloat = NodeView.titleHeight
    public static let maxHeight: CGFloat = NodeView.titleHeight + NodeView.imageHeight
    private static let titleHeight: CGFloat = 30
    private static let imageHeight: CGFloat = NodeView.width
    private static let countCorrespondsMaxHeight: CGFloat = 5
    private static let hStackSpace: CGFloat = vStackSpace
    public static let vStackSpace: CGFloat = (NodeView.maxHeight - NodeView.minHeight * NodeView.countCorrespondsMaxHeight) / (NodeView.countCorrespondsMaxHeight - 1)
    public static let snapX = NodeView.width + NodeView.hStackSpace
    public static let snapY = NodeView.minHeight + NodeView.vStackSpace
    public static let shadow: CGFloat = 3
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if isEditing {
                    TextField("Node Title", text: $inputText, onEditingChanged: { isStart in
                        if !isStart && !onCreation {
                            isEditing = false
                            node.setTitle(title: inputText)
                        }
                        
                        onCreation = false
                    })
                    .font(.headline.weight(.light))
                    .focused($isFocus)
                    .foregroundColor(LCConstants.textColor)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(height: NodeView.titleHeight)
                } else {
                    Text("\(node.title)")
                        .foregroundColor(LCConstants.textColor)
                        .font(.headline)
                        .frame(height: NodeView.titleHeight)
                        .scaleEffect(isHoveringText ? 1.1 : 1.0)
                        .onHover { hovering in
                            withAnimation(.spring(duration: 0.1)) {
                                isHoveringText = hovering
                            }
                        }
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
            .LCContainer(level: 3, noShadow: true)
            .photosPicker(isPresented: $isPickerPresenting, selection: $selectedItem, matching: .images, photoLibrary: .shared())
            .onChange(of: selectedItem) { _, newItem in
                loadImage(photoPickerItem: newItem)
            }
            .overlay {
                if node.isExpandable {
                    let lineWidth = isHovering ? 2.0 : 1.0
                    let lineColor = LCConstants.getColor(node.isExpanded ? 3 : 4)
                    
                    RoundedRectangle(cornerRadius: LCConstants.cornerRadius)
                        .stroke(lineColor, lineWidth: lineWidth)
                        .blur(radius: isHovering ? 0.1 : 0.0)
                        .brightness(isHovering ? 0.1 : 0.0)
                }
                
                if ((isHovering && !isDragging)) {
                    let topLeft = CGPoint(x: -NodeView.width / 2, y: -node.height / 2)
                    let symbolSize = 11.0
                    let level = 101
                    
                    Button(action: {
                        deleteThisNode()
                    }) {
                        Image(systemName: "minus")
                            .LCButtonMini(width: symbolSize, height: symbolSize, level: level)
                    }
                    .buttonStyle(.plain)
                    .offset(x: topLeft.x, y: topLeft.y)
                    
                    Button(action: {
                        isPickerPresenting.toggle()
                    }) {
                        Image(systemName: "photo.fill")
                            .LCButtonMini(width: symbolSize, height: symbolSize, level: level)
                    }
                    .buttonStyle(.plain)
                    .offset(x: topLeft.x, y: topLeft.y + NodeView.minHeight)
                    
                    if hasImage {
                        Button(action: {
                            deleteImage()
                        }) {
                            Image(systemName: "photo")
                                .LCButtonMini(width: symbolSize, height: symbolSize, level: level)
                        }
                        .buttonStyle(.plain)
                        .offset(x: topLeft.x, y: topLeft.y + 3 * NodeView.minHeight / 2)
                    }
                    
                    Button(action: {
                        createChildNode()
                    }) {
                        Image(systemName: "plus")
                            .LCButtonMini(width: symbolSize, height: symbolSize, level: level)
                    }
                    .buttonStyle(.plain)
                    .offset(x: -topLeft.x, y: topLeft.y + NodeView.minHeight / 2)
                }
            }
        }
        .onHover { hovering in
            withAnimation(.spring(duration:0.5)) {
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
                inputText = "Title"
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
                node.rearrangeSiblingsPositionY()
            }
        }
        .position(CGPoint(x: CGFloat(node.globalPositionX), y: CGFloat(node.globalPositionY)))
        .onTapGesture(count: 1) {
            withAnimation {
                node.toggleExpand()
            }
        }
        .gesture(DragGesture()
            .onChanged(onDrag)
            .onEnded(onDragEnd)
        )
        
        if node.canShowChildren {
            let padding: Double = 3.0
            let textPadding = 10.0
            let cornerRadius = LCConstants.cornerRadius + padding / 2
            
            Rectangle()
                .opacity(0)
                .frame(width: padding * 2, height: node.height - cornerRadius)
                .LCContainer(smooth: 2, radius: padding, level: 2, noShadow: false)
                .position(CGPoint(x: CGFloat((node.contentGlobalPositionX + node.globalPositionX) / 2), y: CGFloat(node.globalPositionY)))
            
            Rectangle()
                .opacity(0)
                .if(!node.isExpanded) {
                    $0.overlay {
                        Text(node.contentInfo)
                            .foregroundColor(LCConstants.textColor)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(EdgeInsets(top: 0, leading: textPadding, bottom: 0, trailing: textPadding))
                    }
                    .onHover { hovering in
                        withAnimation(.spring(duration:0.5)) {
                            isHovering = hovering
                        }
                    }
                    .onTapGesture(count: 1) {
                        withAnimation {
                            node.toggleExpand()
                        }
                    }
                }
                .frame(width: NodeView.width + padding * 2, height: node.contentHeight + padding * 2)
                .LCContainer(radius: cornerRadius, level: 2, noShadow: true)
                .position(CGPoint(x: CGFloat(node.contentGlobalPositionX), y: CGFloat(node.contentGlobalPositionY)))
        }
    }
    
    private func onDrag(value: DragGesture.Value) {
        let currentPos = value.location
        let deltaX = currentPos.x - node.lastGlobalPositionX
        let deltaY = currentPos.y - node.lastGlobalPositionY
        let localPositionX = node.lastLocalPositionX + (node.hasParent ? (deltaX.sign() * (4.0 * 8.0 * abs(deltaX)).squareRoot()) : deltaX)
        let localPositionY = node.lastLocalPositionY + deltaY
        
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 20)) {
            isDragging = true
            node.setLocalPosition(positionX: localPositionX, positionY: localPositionY)
        }
        
        if let parent = node.parent {
            for sibling in parent.children {
                if (node.globalPositionY > sibling.globalPositionY && node.order < sibling.order) ||
                    (node.globalPositionY < sibling.globalPositionY && node.order > sibling.order)
                {
                    let tmpOrder = node.order
                    node.order = sibling.order
                    sibling.order = tmpOrder
                    
                    withAnimation(.interpolatingSpring(stiffness: 300, damping: 20)) {
                        node.rearrangeSiblingsPositionY()
                    }
                }
            }
            
            if abs(deltaX) > 135
            {
                withAnimation(.interpolatingSpring(stiffness: 300, damping: 25)) {
                    node.removeParent()
                    parent.rearrangeChildrenPositionY()
                    parent.rearrangeSiblingsPositionY()
                }
            }
        }
    }
    
    private func onDragEnd(value: DragGesture.Value) {
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 20)) {
            isDragging = false
            
            if node.parent != nil {
                node.rearrangeSiblingsPositionY()
            } else {
                node.snapToGrid()
            }
        }
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
    
    private func deleteThisNode() {
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 25)) {
            isDeleting = true
            node.isExpanded = true
            
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
                
                if let prnt = parent {
                    prnt.rearrangeChildrenPositionY()
                    prnt.rearrangeSiblingsPositionY()
                }
                
                for child in children {
                    child.snapToGrid()
                }
            } else {
                isDeleting = false
            }
        }
    }
    
    private func createChildNode() {
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 25)) {
            createNode("tite", node)
            node.rearrangeChildrenPositionY()
            node.rearrangeSiblingsPositionY()
        }
    }
    
    private func fetchMeaning(word: String) {
        /*
        self.isEditing = false
        gptService.fetchMeaning(for: word) { meaning in
            if let meaning = meaning {
                DispatchQueue.main.async {
                    node.title = meaning
                }
            }
        }
         */
    }
}
