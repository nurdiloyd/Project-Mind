import SwiftUI

struct NodeContainerBottomView: View {
    var buttonAction: () -> Void
    public static var height: CGFloat = 30
    
    var body: some View {
        HStack {
            Button(action: {
                buttonAction()
            }) {
                Image(systemName: "trash")
                    .bold()
                    .frame(maxHeight: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(height: NodeContainerBottomView.height)
        .shadow(radius: 8)
    }
}
