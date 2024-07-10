import SwiftData
import Foundation

@Model
final class BoardData: Codable {
    @Attribute(.unique) var id: UUID
    var title: String
    @Relationship var nodes: [NodeData] = []

    init(id: UUID = UUID(), title: String) {
        self.id = id
        self.title = title
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case nodes
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(nodes, forKey: .nodes)
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let title = try container.decode(String.self, forKey: .title)
        let nodes = try container.decode([NodeData].self, forKey: .nodes)
        self.init(id: id, title: title)
        self.nodes = nodes
    }
}
