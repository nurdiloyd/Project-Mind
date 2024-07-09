import SwiftUI

struct EntranceView: View {
    var onStart: () -> Void
    
    var body: some View {
        VStack {
            Image(systemName: "sun.max")
                .resizable()
                .frame(width: 100, height: 100)
            
            Button(action: onStart) {
                Text("Start")
                    .font(.title)
                    .padding()
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .safeAreaPadding(.all)
        .toolbar {
            ToolbarItem {
                Button {
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

struct EntranceView_Previews: PreviewProvider {
    static var previews: some View {
        EntranceView(onStart: {})
    }
}
