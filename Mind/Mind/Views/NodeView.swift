import SwiftUI
import PhotosUI

struct NodeView: View {
    public let node: NodeData
    public var createNode: () -> NodeData
    public var deleteNode: (NodeData) -> Bool
    public var board: BoardData
    
    @FocusState private var isFocus: Bool
    @State private var inputText: String = ""
    @State private var isEditing: Bool = false
    @State private var isDragging: Bool = false
    @State private var waitForIt: Bool = false
    @State private var isHovering: Bool = false
    @State private var isHoveringText: Bool = false
    @State private var isDeleting: Bool = false
    @State private var isPickerPresenting: Bool = false
    @State private var isAddingImage: Bool = false
    @State private var onCreation: Bool = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var imageLoadingOnLoad: Bool = true
    @State private var image: NSImage? = nil
    @State private var currentNearestNode: NodeData? = nil
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
                    TextField("Node Title", text: $inputText, onCommit: onEditTextFieldEnd)
                    .font(.headline.weight(.light))
                    .focused($isFocus)
                    .foregroundColor(LCConstants.textColor)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(height: NodeView.titleHeight)
                } else {
                    let noTitle = node.title.isEmptyOrWithWhiteSpace
                    Text("\(noTitle  ? "NodeTitle" : node.title)")
                        .foregroundColor(LCConstants.textColor)
                        .if(noTitle) {
                            $0.font(.subheadline).italic()
                        }
                        .if(!noTitle) {
                            $0.font(.headline)
                        }
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
            .LCContainer(level: 3, opacity: 0.8)
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
                    let symbolSize = LCConstants.cornerRadius
                    let level = 101
                    
                    Button(action: {
                        deleteThisNode()
                    }) {
                        Image(systemName: "minus")
                            .LCButtonMini(width: symbolSize, height: symbolSize, level: level)
                    }
                    .buttonStyle(.plain)
                    .offset(x: topLeft.x + symbolSize / 2, y: topLeft.y + symbolSize / 2)
                    
                    Button(action: {
                        isPickerPresenting.toggle()
                    }) {
                        Image(systemName: "photo.fill")
                            .LCButtonMini(width: symbolSize, height: symbolSize, level: level)
                    }
                    .buttonStyle(.plain)
                    .offset(x: topLeft.x + symbolSize / 2, y: topLeft.y + NodeView.minHeight - symbolSize / 2)
                    
                    if hasImage {
                        Button(action: {
                            deleteImage()
                        }) {
                            Image(systemName: "photo")
                                .LCButtonMini(width: symbolSize, height: symbolSize, level: level)
                        }
                        .buttonStyle(.plain)
                        .offset(x: topLeft.x + symbolSize / 2, y: topLeft.y + NodeView.minHeight + symbolSize / 2)
                    }
                    
                    Button(action: {
                        createNode(parent: node)
                    }) {
                        Image(systemName: "plus")
                            .LCButtonMini(width: symbolSize, height: symbolSize, level: level)
                    }
                    .buttonStyle(.plain)
                    .offset(x: -topLeft.x - symbolSize / 2, y: topLeft.y + NodeView.minHeight / 2)
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
        .onAppear { loadNode() }
        .readSize { newSize in
            if !imageLoadingOnLoad
            {
                withAnimation(.interpolatingSpring(stiffness: 300, damping: 25)) {
                    node.setHeight(height: newSize.height)
                }
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
                .LCContainer(radius: cornerRadius, level: 2, opacity: 0.7)
                .position(CGPoint(x: CGFloat(node.contentGlobalPositionX), y: CGFloat(node.contentGlobalPositionY)))
            
            Rectangle()
                .opacity(0)
                .frame(width: padding * 2, height: NodeView.minHeight - cornerRadius)
                .LCContainer(smooth: 2, radius: padding, level: 2, opacity: 0.7)
                .position(CGPoint(x: CGFloat((node.contentGlobalPositionX + node.globalPositionX) / 2), y: CGFloat(node.globalPositionY)))
            
        }
    }
    
    private func loadNode() {
        if !node.isInit
        {
            node.isInit = true
            onCreation = true
            isEditing = true
            isFocus.toggle()
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
    
    private func onEditTextFieldEnd() {
        if isFocus {
            isEditing = false
            node.setTitle(title: inputText)
            
            if node.title.isEmptyOrWithWhiteSpace
            {
                deleteThisNode()
            }
            else
            {
                if onCreation && node.isLastChild {
                    if let parent = node.parent
                    {
                        createNode(parent: parent)
                    }
                }
                else {
                    createNode(parent: node)
                }
                
                onCreation = false
                isFocus = false
            }
        }
    }
    
    private func onDrag(value: DragGesture.Value) {
        if !isDragging
        {
            currentNearestNode = nil
            IntersectionManager.shared.stopAllTimers()
        }
        
        let currentPos = value.location
        let difX = currentPos.x - node.lastGlobalPositionX
        let deltaX = node.hasParent && !waitForIt
                      ? difX.sign() * (4.0 * 8.0 * abs(difX)).squareRoot()
                      : difX
        let deltaY = currentPos.y - node.lastGlobalPositionY
        let localPositionX = node.lastLocalPositionX + deltaX
        let localPositionY = node.lastLocalPositionY + deltaY
        
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 20)) {
            isDragging = true
        }
        
        node.setLocalPosition(positionX: localPositionX, positionY: localPositionY)
        
        if let parent = node.parent {
            for sibling in parent.children {
                if (node.globalPositionY > sibling.globalPositionY && node.order < sibling.order) ||
                    (node.globalPositionY < sibling.globalPositionY && node.order > sibling.order)
                {
                    let tmpOrder = node.order
                    node.order = sibling.order
                    sibling.order = tmpOrder
                    
                    withAnimation(.interpolatingSpring(stiffness: 300, damping: 20)) {
                        parent.rearrangeSelf()
                    }
                    
                    node.setLocalPosition(positionX: localPositionX, positionY: localPositionY)
                }
            }
            
            if !waitForIt && abs(difX) > 135
            {
                withAnimation(.interpolatingSpring(stiffness: 300, damping: 25)) {
                    node.removeParent()
                }
            }
        }
        
        if waitForIt && abs(difX) < 85 {
            waitForIt = false
        }
        
        checkForOverlap(currentPos: currentPos)
    }
    
    private func checkForOverlap(currentPos: CGPoint) {
        let width = NodeView.width
        let currentNodeFrame = CGRect(x: node.globalPositionX - width / 2, y: node.globalPositionY - node.height / 2, width: width, height: node.height)
        
        var nearestNode: NodeData? = nil
        var nearestDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        for otherNode in board.nodes where (otherNode.shouldShowSelf && otherNode.id != node.id) {
            let otherNodeFrame = CGRect(x: otherNode.globalPositionX - width / 2, y: otherNode.globalPositionY - otherNode.height / 2, width: width, height: otherNode.height)
            
            if currentNodeFrame.intersects(otherNodeFrame) {
                let distance = hypot(node.globalPositionX - otherNode.globalPositionX, node.globalPositionY - otherNode.globalPositionY)
                if distance < nearestDistance {
                    nearestDistance = distance
                    nearestNode = otherNode
                }
            }
        }

        if let nearestNode = nearestNode {
            if currentNearestNode != nearestNode && nearestNode != node.parent {
                currentNearestNode = nearestNode
                IntersectionManager.shared.stopAllTimers()
                
                IntersectionManager.shared.startIntersectionTimer(node1: node, node2: nearestNode) {
                    DispatchQueue.main.async {
                        let currentNodeFrame = CGRect(x: node.globalPositionX - width / 2, y: node.globalPositionY - node.height / 2, width: width, height: node.height)
                        let otherNodeFrame = CGRect(x: nearestNode.globalPositionX - width / 2, y: nearestNode.globalPositionY - nearestNode.height / 2, width: width, height: nearestNode.height)
                        if currentNodeFrame.intersects(otherNodeFrame) {
                            waitForIt = true
                            setParent(parent: nearestNode)
                        }
                    }
                }
            }
        } else {
            currentNearestNode = nil
            IntersectionManager.shared.stopAllTimers()
        }
    }
    
    private func setParent(parent: NodeData) {
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 20)) {
            let prePosX = node.globalPositionX
            let prePosY = node.globalPositionY
            
            node.removeParent()
            
            let posX = prePosX - parent.globalPositionX
            let posY = prePosY - parent.globalPositionY
            
            parent.addChild(node)
            
            if isDragging {
                node.setLocalPosition(positionX: posX, positionY: posY)
            }
        }
    }
    
    private func onDragEnd(value: DragGesture.Value) {
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 20)) {
            isDragging = false
            
            if node.parent != nil {
                node.place(positionX: node.lastLocalPositionX, positionY: node.lastLocalPositionY, snap: false)
            } else {
                node.place(positionX: node.localPositionX, positionY: node.localPositionY)
            }
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
                            //DispatchQueue.global(qos: .utility).async {
                            let imageName = "image_\(UUID().uuidString).jpeg"
                            FileHelper.saveImage(data: compressedImageData, filename: imageName)
                            
                            DispatchQueue.main.async {
                                self.image = NSImage(data: compressedImageData)
                                self.node.imageName = imageName
                            }
                            //}
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
            
            if !deleteNode(node)
            {
                isDeleting = false
            }
        }
    }
    
    private func createNode(parent: NodeData) {
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 25)) {
            let newNode = createNode()
            parent.addChild(newNode)
        }
    }
}
