import SwiftData
import Foundation

@Model
final class NodeData: Codable {
    @Attribute(.unique) var id: UUID
    var title: String = ""
    var globalPositionX: Double { localPositionX + (parent?.globalPositionX ?? 0) }
    var globalPositionY: Double { localPositionY + (parent?.globalPositionY ?? 0) }
    var localPositionX: Double = 0
    var localPositionY: Double = 0
    var lastPositionX: Double = 0
    var lastPositionY: Double = 0
    var imageName: String? = nil
    var order: Int = 0
    @Relationship var parent: NodeData? = nil
    @Relationship(inverse: \NodeData.parent) var children: [NodeData] = []
    var containerHeight: Double = 106
    
    init(id: UUID = UUID(), title: String, positionX: Double, positionY: Double, imageName: String? = nil, parent: NodeData? = nil, containerHeight: Double = 106, order: Int = 0) {
        self.id = id
        self.localPositionX = positionX
        self.localPositionY = positionY
        self.lastPositionX = positionX
        self.lastPositionY = positionY
        self.imageName = imageName
        self.parent = parent
        self.containerHeight = containerHeight
        self.order = order
        self.title = "\(title)"
        
        parent?.addChild(node: self)
    }

    private func addChild(node: NodeData) {
        node.order = (children.max(by: { $0.order < $1.order })?.order ?? 0) + 1
        children.append(node)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case localPositionX
        case localPositionY
        case lastPositionX
        case lastPositionY
        case imageName
        case order
        case parentID
        case children
        case containerHeight
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(localPositionX, forKey: .localPositionX)
        try container.encode(localPositionY, forKey: .localPositionY)
        try container.encode(lastPositionX, forKey: .lastPositionX)
        try container.encode(lastPositionY, forKey: .lastPositionY)
        try container.encode(imageName, forKey: .imageName)
        try container.encode(order, forKey: .order)
        try container.encode(containerHeight, forKey: .containerHeight)
        try container.encode(children, forKey: .children)
        if let parent = parent {
            try container.encode(parent.id, forKey: .parentID)
        }
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let title = try container.decode(String.self, forKey: .title)
        let localPositionX = try container.decode(Double.self, forKey: .localPositionX)
        let localPositionY = try container.decode(Double.self, forKey: .localPositionY)
        let lastPositionX = try container.decode(Double.self, forKey: .lastPositionX)
        let lastPositionY = try container.decode(Double.self, forKey: .lastPositionY)
        let imageName = try container.decode(String?.self, forKey: .imageName)
        let order = try container.decode(Int.self, forKey: .order)
        let containerHeight = try container.decode(Double.self, forKey: .containerHeight)
        let parentID = try container.decodeIfPresent(UUID.self, forKey: .parentID)
        let children = try container.decode([NodeData].self, forKey: .children)

        self.init(id: id, title: title, positionX: localPositionX, positionY: localPositionY, imageName: imageName, parent: nil, containerHeight: containerHeight, order: order)
        self.children = children
    }
}
