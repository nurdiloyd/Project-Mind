import SwiftUI

class IntersectionManager {
    static let shared = IntersectionManager()
    private var intersections: [String: Timer] = [:]

    private func intersectionKey(node1: NodeData, node2: NodeData) -> String {
        return "\(node1.id.uuidString)_\(node2.id.uuidString)"
    }

    func startIntersectionTimer(node1: NodeData, node2: NodeData, completion: @escaping () -> Void) {
        let key = intersectionKey(node1: node1, node2: node2)
        
        if intersections[key] == nil {
            let timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                completion()
            }
            
            intersections[key] = timer
        }
    }

    func stopIntersectionTimer(node1: NodeData, node2: NodeData) {
        let key = intersectionKey(node1: node1, node2: node2)
        intersections[key]?.invalidate()
        intersections[key] = nil
    }

    func stopAllTimers(for node: NodeData) {
        for key in intersections.keys where key.contains(node.id.uuidString) {
            intersections[key]?.invalidate()
            intersections[key] = nil
        }
    }
}
