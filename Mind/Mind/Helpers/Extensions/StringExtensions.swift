import Foundation

extension String {
    var isEmptyOrWithWhiteSpace: Bool {
        self.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
