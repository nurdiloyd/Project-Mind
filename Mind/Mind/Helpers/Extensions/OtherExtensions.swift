import Foundation

extension String {
    var isEmptyOrWithWhiteSpace: Bool {
        self.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
