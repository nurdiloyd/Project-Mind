import SwiftData
import Foundation

@Model
class BoardData {
    @Attribute(.unique) var id: UUID
    var title: String
    @Relationship var nodes: [NodeData] = []
    var isInit: Bool = false
    var isflashCardView: Bool = false
    
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
    
    public func toggleView()
    {
        isflashCardView.toggle()
    }
}
