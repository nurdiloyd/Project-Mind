import SwiftUI

struct GPTTest: View {
    @State private var inputText: String = "Nurdi"
    @State private var isEditing: Bool = false
    @State private var gptService = GPTService()
    
    var body: some View {
        VStack {
            if isEditing {
                TextField("Node Title", text: $inputText)
                .onSubmit {
                    fetchMeaning()
                }
            } else {
                Text(inputText)
                .onTapGesture {
                    isEditing.toggle()
                }
            }
        }
        .frame(width: 200, height: 40)
    }
    
    private func fetchMeaning() {
        self.isEditing = false
        gptService.fetchMeaning(for: inputText) { meaning in
            if let meaning = meaning {
                DispatchQueue.main.async {
                    self.inputText = meaning
                }
            }
        }
    }
}
