import SwiftData
import Foundation

@Model
class BoardData: Codable {
    @Attribute(.unique) var id: UUID
    var title: String
    @Relationship var nodes: [NodeData] = []
    var isInit: Bool = false
    var isFlashCardView: Bool = false
    
    init(title: String) {
        self.id = UUID()
        self.title = title
    }
    
    public func setTitle(title: String) {
        let trimmedTitle = title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTitle.isEmptyOrWithWhiteSpace {
            self.title = trimmedTitle
        }
    }
    
    public func toggleView() {
        isFlashCardView.toggle()
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case nodes
        case isInit
        case isFlashCardView
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        nodes = try container.decode([NodeData].self, forKey: .nodes)
        isInit = try container.decode(Bool.self, forKey: .isInit)
        isFlashCardView = try container.decode(Bool.self, forKey: .isFlashCardView)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(nodes, forKey: .nodes)
        try container.encode(isInit, forKey: .isInit)
        try container.encode(isFlashCardView, forKey: .isFlashCardView)
    }
}
